import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaDetalhesVeiculo extends StatefulWidget {
  final String veiculoId;
  final String veiculoNome;

  TelaDetalhesVeiculo({required this.veiculoId, required this.veiculoNome});

  @override
  _TelaDetalhesVeiculoState createState() => _TelaDetalhesVeiculoState();
}

class _TelaDetalhesVeiculoState extends State<TelaDetalhesVeiculo> {
  double? _mediaConsumo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calcularMediaConsumo();
  }

 Future<void> _calcularMediaConsumo() async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('abastecimentos')
          .where('veiculoId', isEqualTo: widget.veiculoId)
          .orderBy('quilometragem')
          .get();

      if (snapshot.docs.isNotEmpty) {
        double kmPercorridos = 0;
        double totalLitrosConsumidos = 0;

        for (var i = 1; i < snapshot.docs.length; i++) {
          final dadosAtual = snapshot.docs[i].data() as Map<String, dynamic>;
          final dadosAnterior = snapshot.docs[i - 1].data() as Map<String, dynamic>;

          final quilometragemAtual = (dadosAtual['quilometragem'] as num).toInt();
          final quilometragemAnterior = (dadosAnterior['quilometragem'] as num).toInt();
          final litrosAnteriores = (dadosAnterior['litros'] as num).toDouble();

          if (litrosAnteriores > 0) {
            kmPercorridos += (quilometragemAtual - quilometragemAnterior);
            totalLitrosConsumidos += litrosAnteriores;
          }
        }

        if (kmPercorridos > 0 && totalLitrosConsumidos > 0) {
          setState(() {
            _mediaConsumo = kmPercorridos / totalLitrosConsumidos;
          });
        } else {
          setState(() {
            _mediaConsumo = 0;
          });
        }
      } else {
        setState(() {
          _mediaConsumo = 0;
        });
      }
    }
  } catch (e) {
    print("Erro ao calcular média de consumo: $e");
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Veículo - ${widget.veiculoNome}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nome do Veículo: ${widget.veiculoNome}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Média de Consumo:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    _mediaConsumo != null
                        ? '${_mediaConsumo!.toStringAsFixed(2)} km/l'
                        : 'Não foi possível calcular.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

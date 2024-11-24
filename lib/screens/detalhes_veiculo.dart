import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaDetalhesVeiculo extends StatelessWidget {
  final String veiculoId;
  final String veiculoNome;

  const TelaDetalhesVeiculo({
    required this.veiculoId,
    required this.veiculoNome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E88E5),
        title: Text(
          'Detalhes do Veículo',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nome do Veículo:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 8),
            Text(
              veiculoNome,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Média de Consumo:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 8),
            FutureBuilder<double>(
              future: _calcularMediaConsumo(veiculoId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Calculando...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    'Erro ao calcular consumo',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  );
                }
                return Text(
                  '${snapshot.data?.toStringAsFixed(2) ?? 'N/A'} km/l',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF03DAC6),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Divider(color: Colors.white24),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<double> _calcularMediaConsumo(String veiculoId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('abastecimentos')
          .where('veiculoId', isEqualTo: veiculoId)
          .orderBy('quilometragem')
          .get();

      if (snapshot.docs.length > 1) {
        double kmPercorridos = 0;
        double totalLitros = 0;

        for (var i = 1; i < snapshot.docs.length; i++) {
          final dadosAtual = snapshot.docs[i].data() as Map<String, dynamic>;
          final dadosAnterior = snapshot.docs[i - 1].data() as Map<String, dynamic>;

          final quilometragemAtual = (dadosAtual['quilometragem'] as num).toDouble();
          final quilometragemAnterior = (dadosAnterior['quilometragem'] as num).toDouble();
          final litrosAbastecidos = (dadosAnterior['litros'] as num).toDouble();

          kmPercorridos += (quilometragemAtual - quilometragemAnterior);
          totalLitros += litrosAbastecidos;
        }

        return kmPercorridos / totalLitros;
      }
    }
    return 0;
  }
}
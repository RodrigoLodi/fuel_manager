import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detalhes_veiculo.dart';

class TelaListaVeiculos extends StatefulWidget {
  @override
  _TelaListaVeiculosState createState() => _TelaListaVeiculosState();
}

class _TelaListaVeiculosState extends State<TelaListaVeiculos> {
  Future<QuerySnapshot> _buscarVeiculos() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      return FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('veiculos')
          .orderBy('criadoEm', descending: true)
          .get();
    }
    throw Exception("Usuário não autenticado!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E88E5),
        title: Text('Meus Veículos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _buscarVeiculos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar veículos',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Nenhum veículo cadastrado',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final veiculos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              final veiculo = veiculos[index];
              final dados = veiculo.data() as Map<String, dynamic>;

              return Card(
                color: Color(0xFF292929),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    dados['nome'] ?? 'Sem nome',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modelo: ${dados['modelo'] ?? 'Sem modelo'} - Ano: ${dados['ano'] ?? 'Sem ano'}',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 4),
                      FutureBuilder<double>(
                        future: _calcularMediaConsumo(veiculo.id),
                        builder: (context, consumoSnapshot) {
                          if (consumoSnapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              'Calculando consumo...',
                              style: TextStyle(color: Colors.white70),
                            );
                          }
                          if (consumoSnapshot.hasError) {
                            return Text(
                              'Erro ao calcular consumo',
                              style: TextStyle(color: Colors.red),
                            );
                          }
                          return Text(
                            'Média: ${consumoSnapshot.data?.toStringAsFixed(2) ?? 'N/A'} km/l',
                            style: TextStyle(color: Color(0xFF03DAC6)),
                          );
                        },
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward, color: Colors.white),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TelaDetalhesVeiculo(
                          veiculoId: veiculo.id,
                          veiculoNome: dados['nome'] ?? 'Sem nome',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
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
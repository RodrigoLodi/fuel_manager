import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaHistoricoAbastecimentos extends StatelessWidget {
  Future<QuerySnapshot> _buscarAbastecimentos() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      return FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('abastecimentos')
          .orderBy('data', descending: true)
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
        title: Text(
          'Histórico de Abastecimentos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _buscarAbastecimentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar abastecimentos',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Nenhum abastecimento registrado',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final abastecimentos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: abastecimentos.length,
            itemBuilder: (context, index) {
              final abastecimento = abastecimentos[index];
              final dados = abastecimento.data() as Map<String, dynamic>;
              final litros = dados['litros'];
              final quilometragem = dados['quilometragem'];
              final data = (dados['data'] as Timestamp).toDate();

              return Card(
                color: Color(0xFF292929),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    'Litros: $litros - Quilometragem: $quilometragem',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    'Data: ${data.day}/${data.month}/${data.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

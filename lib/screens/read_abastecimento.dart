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
      appBar: AppBar(
        title: Text('Histórico de Abastecimentos'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _buscarAbastecimentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar abastecimentos'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum abastecimento registrado'));
          }

          final abastecimentos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: abastecimentos.length,
            itemBuilder: (context, index) {
              final abastecimento = abastecimentos[index];
              final dados = abastecimento.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(
                    'Litros: ${dados['litros']} - Quilometragem: ${dados['quilometragem']}'),
                subtitle: Text('Data: ${dados['data'].toDate().toString()}'),
              );
            },
          );
        },
      ),
    );
  }
}

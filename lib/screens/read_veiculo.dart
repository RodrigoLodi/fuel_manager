import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaListaVeiculos extends StatelessWidget {
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
      appBar: AppBar(
        title: Text('Meus Veículos'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _buscarVeiculos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar veículos'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum veículo cadastrado'));
          }

          final veiculos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              final veiculo = veiculos[index];
              final dados = veiculo.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(dados['nome'] ?? 'Sem nome'),
                subtitle: Text('${dados['modelo'] ?? ''} - ${dados['ano'] ?? ''}'),
                trailing: Text(dados['placa'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}

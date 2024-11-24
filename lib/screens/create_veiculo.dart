import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaAdicionarVeiculo extends StatelessWidget {
  final _nomeController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _placaController = TextEditingController();

  Future<void> salvarVeiculo() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .collection('veiculos')
            .add({
          'nome': _nomeController.text.trim(),
          'modelo': _modeloController.text.trim(),
          'ano': _anoController.text.trim(),
          'placa': _placaController.text.trim(),
          'criadoEm': DateTime.now(),
        });

        print("Veículo salvo com sucesso!");
      } else {
        print("Usuário não autenticado!");
      }
    } catch (erro) {
      print("Erro ao salvar veículo: $erro");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Veículo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome do Veículo'),
            ),
            TextField(
              controller: _modeloController,
              decoration: InputDecoration(labelText: 'Modelo'),
            ),
            TextField(
              controller: _anoController,
              decoration: InputDecoration(labelText: 'Ano'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _placaController,
              decoration: InputDecoration(labelText: 'Placa'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await salvarVeiculo();
                Navigator.pop(context);
              },
              child: Text('Salvar Veículo'),
            ),
          ],
        ),
      ),
    );
  }
}

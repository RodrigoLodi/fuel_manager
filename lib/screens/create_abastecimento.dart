import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TelaAdicionarAbastecimento extends StatefulWidget {
  @override
  _TelaAdicionarAbastecimentoState createState() =>
      _TelaAdicionarAbastecimentoState();
}

class _TelaAdicionarAbastecimentoState
    extends State<TelaAdicionarAbastecimento> {
  final _litrosController = TextEditingController();
  final _quilometragemController = TextEditingController();
  DateTime? _dataSelecionada;
  String? _veiculoSelecionado;
  List<Map<String, dynamic>> _listaVeiculos = [];

  @override
  void initState() {
    super.initState();
    _carregarVeiculos();
  }

  Future<void> _carregarVeiculos() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .collection('veiculos')
            .get();

        setState(() {
          _listaVeiculos = snapshot.docs.map((doc) {
            final dados = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'nome': dados['nome'] ?? 'Sem nome',
            };
          }).toList();
        });
      }
    } catch (erro) {
      print("Erro ao carregar veículos: $erro");
    }
  }

  Future<void> salvarAbastecimento() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null && _veiculoSelecionado != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .collection('abastecimentos')
            .add({
          'veiculoId': _veiculoSelecionado,
          'litros': double.parse(_litrosController.text.trim()),
          'quilometragem': int.parse(_quilometragemController.text.trim()),
          'data': _dataSelecionada ?? DateTime.now(),
          'criadoEm': DateTime.now(),
        });

        print("Abastecimento salvo com sucesso!");
        Navigator.pop(context);
      } else {
        print("Usuário ou veículo não autenticado!");
      }
    } catch (erro) {
      print("Erro ao salvar abastecimento: $erro");
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoData = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Abastecimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _veiculoSelecionado,
              hint: Text('Selecione o Veículo'),
              items: _listaVeiculos.map<DropdownMenuItem<String>>((veiculo) {
                return DropdownMenuItem<String>(
                  value: veiculo['id'] as String,
                  child: Text(veiculo['nome'] as String),
                );
              }).toList(),
              onChanged: (novoVeiculoId) {
                setState(() {
                  _veiculoSelecionado = novoVeiculoId;
                });
              },
            ),

            SizedBox(height: 20),
            TextField(
              controller: _litrosController,
              decoration: InputDecoration(labelText: 'Litros Abastecidos'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _quilometragemController,
              decoration: InputDecoration(labelText: 'Quilometragem Atual'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  _dataSelecionada == null
                      ? 'Data: Não selecionada'
                      : 'Data: ${formatoData.format(_dataSelecionada!)}',
                ),
                Spacer(),
                TextButton(
                  onPressed: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (data != null) {
                      setState(() {
                        _dataSelecionada = data;
                      });
                    }
                  },
                  child: Text('Selecionar Data'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvarAbastecimento,
              child: Text('Salvar Abastecimento'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaAdicionarAbastecimento extends StatefulWidget {
  @override
  _TelaAdicionarAbastecimentoState createState() =>
      _TelaAdicionarAbastecimentoState();
}

class _TelaAdicionarAbastecimentoState
    extends State<TelaAdicionarAbastecimento> {
  String? _veiculoSelecionado;
  final _litrosController = TextEditingController();
  final _quilometragemController = TextEditingController();
  DateTime? _dataSelecionada;
  bool _isLoading = false;

  Future<void> _salvarAbastecimento() async {
    if (_veiculoSelecionado == null ||
        _litrosController.text.isEmpty ||
        _quilometragemController.text.isEmpty ||
        _dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .collection('abastecimentos')
            .add({
          'veiculoId': _veiculoSelecionado,
          'litros': double.parse(_litrosController.text.trim()),
          'quilometragem': double.parse(_quilometragemController.text.trim()),
          'data': _dataSelecionada,
          'criadoEm': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abastecimento salvo com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar abastecimento.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

Future<List<Map<String, String>>> _buscarVeiculos() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('veiculos')
        .get();

    return snapshot.docs.map((doc) {
      final dados = doc.data();
      return {
        'id': doc.id,
        'nome': dados['nome']?.toString() ?? 'Sem nome',
      };
    }).toList();
  }
  return [];
}


  void _selecionarData(BuildContext context) async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E88E5),
        title: Text(
          'Adicionar Abastecimento',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<List<Map<String, String>>>(
              future: _buscarVeiculos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'Nenhum veículo disponível',
                    style: TextStyle(color: Colors.white70),
                  );
                }

                final veiculos = snapshot.data!;
                return DropdownButtonFormField<String>(
                  value: _veiculoSelecionado,
                  dropdownColor: Color(0xFF292929),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    labelText: 'Selecione o Veículo',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  items: veiculos
                      .map((veiculo) => DropdownMenuItem<String>(
                            value: veiculo['id'],
                            child: Text(
                              veiculo['nome']!,
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _veiculoSelecionado = value;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _litrosController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Litros Abastecidos',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _quilometragemController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Quilometragem Atual',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dataSelecionada == null
                        ? 'Data: Não selecionada'
                        : 'Data: ${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => _selecionarData(context),
                  child: Text(
                    'Selecionar Data',
                    style: TextStyle(color: Color(0xFF1E88E5)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _salvarAbastecimento,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF03DAC6),
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Salvar Abastecimento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaCadastro extends StatefulWidget {
  @override
  _TelaCadastroState createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _campoEmail = TextEditingController();
  final _campoSenha = TextEditingController();

  Future<void> fazerCadastro() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _campoEmail.text.trim(),
        password: _campoSenha.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (erro) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(erro.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _campoEmail,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _campoSenha,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fazerCadastro,
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}

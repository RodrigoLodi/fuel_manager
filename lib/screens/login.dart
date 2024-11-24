import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaLogin extends StatefulWidget {
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _campoEmail = TextEditingController();
  final _campoSenha = TextEditingController();

  Future<void> fazerLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
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
      appBar: AppBar(title: Text('Login')),
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
              onPressed: fazerLogin,
              child: Text('Entrar'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text('Não tem uma conta? Cadastre-se'),
            ),
            TextButton(
              onPressed: () async {
                if (_campoEmail.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Insira seu email para recuperar a senha.'),
                  ));
                } else {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: _campoEmail.text.trim(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Email de recuperação enviado!'),
                    ));
                  } catch (erro) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(erro.toString()),
                    ));
                  }
                }
              },
              child: Text('Esqueceu sua senha?'),
            ),
          ],
        ),
      ),
    );
  }
}

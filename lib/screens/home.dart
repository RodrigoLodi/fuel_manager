import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela Principal'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Nome do Usuário'),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? 'Usuário não autenticado',
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  FirebaseAuth.instance.currentUser?.email?.substring(0, 1).toUpperCase() ?? '?',
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_car),
              title: Text('Meus Veículos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/meusVeiculos');
              },
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text('Adicionar Veículo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/adicionarVeiculo');
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Histórico de Abastecimentos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/historicoAbastecimentos');
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/perfil');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Bem-vindo à Tela Principal!'),
      ),
    );
  }
}
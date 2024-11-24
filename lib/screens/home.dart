import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaPrincipal extends StatelessWidget {
  Future<String> _buscarNomeUsuario() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        final dados = snapshot.data() as Map<String, dynamic>;
        return dados['nome'] ?? 'Nome do Usuário';
      }
    }

    return 'Nome do Usuário';
  }

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
              accountName: FutureBuilder<String>(
                future: _buscarNomeUsuario(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Carregando...');
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar nome');
                  } else {
                    return Text(snapshot.data ?? 'Nome do Usuário');
                  }
                },
              ),
              accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? 'Sem email'),
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
              leading: Icon(Icons.local_gas_station),
              title: Text('Registrar Abastecimento'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/adicionarAbastecimento');
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
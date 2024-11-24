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
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E88E5),
        title: Text('Tela Principal', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFF1E1E1E),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1E88E5),
              ),
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
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? 'Sem email',
                style: TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Color(0xFF03DAC6),
                child: Text(
                  FirebaseAuth.instance.currentUser?.email?.substring(0, 1).toUpperCase() ?? '?',
                  style: TextStyle(fontSize: 40.0, color: Colors.black),
                ),
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.home,
              title: 'Home',
              routeName: '/home',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.directions_car,
              title: 'Meus Veículos',
              routeName: '/meusVeiculos',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.add_circle_outline,
              title: 'Adicionar Veículo',
              routeName: '/adicionarVeiculo',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.local_gas_station,
              title: 'Registrar Abastecimento',
              routeName: '/adicionarAbastecimento',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.history,
              title: 'Histórico de Abastecimentos',
              routeName: '/historicoAbastecimentos',
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person,
              title: 'Perfil',
              routeName: '/perfil',
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Logout', style: TextStyle(color: Colors.white)),
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
        child: Text(
          'Bem-vindo à Tela Principal!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String title, required String routeName}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName);
      },
    );
  }
}
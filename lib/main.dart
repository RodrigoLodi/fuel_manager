import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/create_veiculo.dart';
import 'screens/read_veiculo.dart';
import 'screens/create_abastecimento.dart';
import 'screens/read_abastecimento.dart';
import 'screens/detalhes_veiculo.dart';
import 'screens/perfil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(GerenciadorAbastecimento());
}

class GerenciadorAbastecimento extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Abastecimento',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => TelaLogin(),
        '/register': (context) => TelaCadastro(),
        '/home': (context) => TelaPrincipal(),
        '/meusVeiculos': (context) => Scaffold(body: Center(child: Text('Meus Veículos'))),
        '/adicionarVeiculo': (context) => Scaffold(body: Center(child: Text('Adicionar Veículo'))),
        '/historicoAbastecimentos': (context) => Scaffold(body: Center(child: Text('Histórico de Abastecimentos'))),
        '/perfil': (context) => Scaffold(body: Center(child: Text('Perfil'))),
        '/adicionarVeiculo': (context) => TelaAdicionarVeiculo(),
        '/meusVeiculos': (context) => TelaListaVeiculos(),
        '/adicionarAbastecimento': (context) => TelaAdicionarAbastecimento(),
        '/historicoAbastecimentos': (context) => TelaHistoricoAbastecimentos(),
        '/perfil': (context) => TelaPerfil(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login.dart';
import 'screens/register.dart';


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
        '/home': (context) => Scaffold(body: Center(child: Text('Página Inicial'))),
      },
    );
  }
}

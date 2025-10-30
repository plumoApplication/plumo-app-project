import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // O MaterialApp será o widget raiz do nosso app
    // No futuro, ele será envolvido pelos nossos BlocProviders
    return MaterialApp(
      // Por enquanto, apenas uma tela de placeholder
      home: Scaffold(
        appBar: AppBar(title: const Text('Plumo')),
        body: const Center(child: Text('Plumo App - Carregando...')),
      ),
    );
  }
}

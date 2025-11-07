import 'package:flutter/material.dart';

class TripSearchPage extends StatelessWidget {
  const TripSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buscar Viagem')),
      body: Center(child: Text('Aba 1: Tela de Busca (De/Para/Data)')),
    );
  }
}

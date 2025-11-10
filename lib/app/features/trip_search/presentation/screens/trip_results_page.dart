import 'package:flutter/material.dart';

class TripResultsPage extends StatelessWidget {
  // No futuro, receberemos os parâmetros de busca aqui
  // final String origin;
  // final String destination;
  // final DateTime date;

  const TripResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Viagens Encontradas')),
      body: const Center(child: Text('Tela de Resultados (Lista de Viagens)')),
    );
  }
}

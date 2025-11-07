import 'package:flutter/material.dart';

class MyTripsPage extends StatelessWidget {
  const MyTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minhas Viagens')),
      body: Center(
        child: Text('Aba 2: Tela de Minhas Viagens (Reservadas/Histórico)'),
      ),
    );
  }
}

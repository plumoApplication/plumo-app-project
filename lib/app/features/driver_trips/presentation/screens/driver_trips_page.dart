import 'package:flutter/material.dart';

class DriverTripsPage extends StatelessWidget {
  const DriverTripsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minhas Viagens (Motorista)')),
      body: Center(child: Text('Aba 1: Gerenciar Viagens')),
    );
  }
}

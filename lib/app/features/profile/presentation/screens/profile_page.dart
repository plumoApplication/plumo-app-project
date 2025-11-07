import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meu Perfil')),
      body: Center(
        child: Text('Aba 3: Tela de Perfil (Editar Dados, Pagamentos, Sair)'),
      ),
    );
  }
}

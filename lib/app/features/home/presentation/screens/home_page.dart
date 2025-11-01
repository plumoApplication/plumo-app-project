import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plumo (Home)'),
        // ADICIONAMOS O BOTÃO DE AÇÃO (LOGOUT)
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              // Ao pressionar, chamamos o 'signOut'
              // do nosso AuthCubit.
              // Usamos context.read<T>() para "chamar" um método.
              context.read<AuthCubit>().signOut();
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Tela Principal (Home) - Você está logado!'),
      ),
    );
  }
}

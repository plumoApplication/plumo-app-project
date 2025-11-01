import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// (Não precisamos mais do 'service_locator.dart' aqui)
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';

import 'package:plumo/app/features/auth/presentation/screens/login_page.dart';
import 'package:plumo/app/features/home/presentation/screens/home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. O 'BlocProvider' FOI REMOVIDO.
    //    Começamos direto com o 'BlocBuilder'.
    // 2. O 'BlocBuilder' irá procurar "para cima"
    //    e encontrar o Cubit fornecido pelo app.dart.
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const HomePage();
        }

        if (state is Unauthenticated || state is AuthError) {
          return const LoginPage();
        }

        // Default (AuthInitial, AuthLoading)
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

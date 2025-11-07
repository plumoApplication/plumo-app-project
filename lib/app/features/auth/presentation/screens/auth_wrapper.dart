import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';
import 'package:plumo/app/features/auth/presentation/screens/login_page.dart';
import 'package:plumo/app/features/profile/presentation/screens/complete_profile_page.dart';
import 'package:plumo/app/features/passenger_shell/presentation/screens/passenger_shell.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // 1. Estado: Logado E Perfil Completo
        if (state is Authenticated) {
          // LÓGICA CORRIGIDA: Mostra o "Invólucro" (Shell)
          return const PassengerShell();
        }

        // 2. Estado: Logado MAS Perfil Incompleto
        if (state is ProfileIncomplete) {
          return const CompleteProfilePage();
        }

        // 3. Estado: Deslogado, Erro ou Sucesso de Cadastro
        if (state is Unauthenticated ||
            state is AuthError ||
            state is AuthSuccess) {
          return const LoginPage();
        }

        // 4. Default (AuthInitial, AuthLoading)
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

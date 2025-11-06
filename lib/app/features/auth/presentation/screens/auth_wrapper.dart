import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// (Não precisamos mais do sl, o app.dart cuida disso)
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';

import 'package:plumo/app/features/auth/presentation/screens/login_page.dart';
import 'package:plumo/app/features/home/presentation/screens/home_page.dart';
// --- IMPORT ADICIONADO ---
import 'package:plumo/app/features/profile/presentation/screens/complete_profile_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // O AuthWrapper agora é só um 'Builder',
    // escutando o Cubit que o app.dart forneceu.
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // --- LÓGICA DE ROTEAMENTO ATUALIZADA ---

        // 1. Estado: Logado E Perfil Completo
        if (state is Authenticated) {
          // (Os dados do perfil 'state.profile' estão disponíveis
          // para passarmos para a HomePage se quisermos)
          return const HomePage();
        }

        // 2. Estado: Logado MAS Perfil Incompleto
        if (state is ProfileIncomplete) {
          // (Os dados 'state.profile' estão disponíveis
          // para passarmos para a CompleteProfilePage)
          return const CompleteProfilePage();
        }

        // 3. Estado: Deslogado ou Erro de Autenticação
        if (state is Unauthenticated ||
            state is AuthError ||
            state is AuthSuccess) {
          // <-- LÓGICA ADICIONADA
          return const LoginPage();
        }

        // 4. Default (AuthInitial, AuthLoading)
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

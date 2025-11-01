import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/auth/presentation/screens/auth_wrapper.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. O 'BlocProvider' agora está AQUI, no topo da árvore.
    return BlocProvider(
      // 2. Usamos o GetIt (sl) para criar o Cubit
      //    e já chamamos o '.checkAuthStatus()'
      create: (context) => sl<AuthCubit>()..checkAuthStatus(),

      // 3. O 'child' (filho) do provider é o nosso MaterialApp
      child: MaterialApp(
        title: 'Plumo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

        // 4. O 'home' continua sendo o AuthWrapper.
        //    A diferença é que o AuthWrapper agora
        //    encontrará o Cubit que foi fornecido AQUI EM CIMA.
        home: const AuthWrapper(),
      ),
    );
  }
}

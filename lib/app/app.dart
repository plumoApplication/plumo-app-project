import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/trip_search_cubit.dart';
import 'package:plumo/app/features/auth/presentation/screens/auth_wrapper.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // --- CORREÇÃO (Passo 23.21) ---
    // 1. Usamos 'MultiBlocProvider' para fornecer
    //    todos os Cubits "globais" (Singletons)
    return MultiBlocProvider(
      providers: [
        // Fornece o AuthCubit (que já era global)
        BlocProvider(create: (context) => sl<AuthCubit>()..checkAuthStatus()),
        // Fornece o TripSearchCubit (o novo Singleton)
        BlocProvider(create: (context) => sl<TripSearchCubit>()),
      ],
      // 2. O 'child' (filho) é o nosso MaterialApp
      child: MaterialApp(
        title: 'Plumo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        // O 'home' continua sendo o AuthWrapper.
        home: const AuthWrapper(),
      ),
    );
    // --- FIM DA CORREÇÃO ---
  }
}

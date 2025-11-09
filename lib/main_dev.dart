import 'package:flutter/material.dart';
import 'package:plumo/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:plumo/app/core/constants/api_constants.dart'; // Nosso arquivo de chaves
import 'package:plumo/app/core/services/service_locator.dart';

Future<void> main() async {
  // Garante que o Flutter está pronto
  WidgetsFlutterBinding.ensureInitialized();

  print("Running in DEV mode");

  // Inicializa o Firebase
  await Firebase.initializeApp();

  // Inicializa o Supabase
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );
  // 2. LINHA ADICIONADA: Chama nosso setup de Injeção de Dependência
  setupServiceLocator();

  // Inicializa e roda o App
  runApp(const App());
}

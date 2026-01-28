import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plumo/app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:plumo/app/core/services/service_locator.dart';

Future<void> main() async {
  // Garante que o Flutter está pronto
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  print("Running in DEV mode");

  // Inicializa o Firebase
  await Firebase.initializeApp();

  // Inicializa o Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception(
      'FATAL ERROR: As chaves SUPABASE_URL ou SUPABASE_ANON_KEY não foram encontradas no arquivo .env. Verifique se o arquivo existe e se as variáveis estão nomeadas corretamente.',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // 2. LINHA ADICIONADA: Chama nosso setup de Injeção de Dependência
  setupServiceLocator();

  // Inicializa e roda o App
  runApp(const App());
}

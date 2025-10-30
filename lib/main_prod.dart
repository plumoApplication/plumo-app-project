// Ponto de entrada para o ambiente de Produção (PROD)
import 'package:flutter/material.dart';
import 'package:plumo/app/app.dart'; // (Iremos criar este arquivo 'app.dart' a seguir)

void main() {
  // Aqui configuraremos coisas específicas do PROD (ex: Supabase Prod)
  print("Running in PROD mode");

  // Inicializa e roda o App
  runApp(const App());
}

// Ponto de entrada para o ambiente de Desenvolvimento (DEV)
import 'package:flutter/material.dart';
import 'package:plumo/app/app.dart'; // (Iremos criar este arquivo 'app.dart' a seguir)

void main() {
  // Aqui configuraremos coisas específicas do DEV (ex: Supabase Dev)
  print("Running in DEV mode");

  // Inicializa e roda o App
  runApp(const App());
}

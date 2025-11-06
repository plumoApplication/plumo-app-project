import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controladores
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Função chamada pelo botão "Cadastrar"
  void _onSignUpPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos o BlocConsumer como widget pai (como na Login)
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // O listener não fará nada, pois o 'builder'
        // (com o scaffoldContext) é mais seguro para
        // mostrar Snackbars e fazer navegação pós-build.
      },
      builder: (context, state) {
        final bool isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Criar Conta')),
          // O Builder nos dá o 'scaffoldContext'
          body: Builder(
            builder: (scaffoldContext) {
              // Se der Erro (ex: e-mail já existe)
              if (state is AuthError) {
                // (Este bloco já existe)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                  context.read<AuthCubit>().clearErrorState();
                });
              }
              // --- BLOCO ADICIONADO ---
              // Se der Sucesso (Conta Criada)
              if (state is AuthSuccess) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // 1. Mostra um SnackBar VERDE (Sucesso)
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green, // Cor de Sucesso
                    ),
                  );
                  // 2. Navega (pop) DE VOLTA para a LoginPage
                  Navigator.of(context).pop();
                });
              }

              // Se der Sucesso (Autenticado)
              if (state is Authenticated) {
                // Fecha (pop) esta tela (pós-build)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Usamos o 'context' (do BlocConsumer)
                  // para navegar, pois ele está abaixo do MaterialApp
                  Navigator.of(context).pop();
                });
              }
              // --- CORREÇÃO DE LÓGICA (Fim) ---

              // O resto da UI (Stack, Form, etc.)
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Campo de E-mail
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@')) {
                                return 'Por favor, insira um e-mail válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Campo de Senha
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Senha (mín. 6 caracteres)',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira uma senha';
                              }
                              if (value.length < 6) {
                                return 'A senha deve ter no mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Campo de Confirmar Senha
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar Senha',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, confirme sua senha';
                              }
                              if (value != _passwordController.text) {
                                return 'As senhas não conferem';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Botão de Cadastrar
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _onSignUpPressed(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cadastrar'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Camada de Loading
                  if (isLoading)
                    Container(
                      color: Colors.black.withAlpha(128),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

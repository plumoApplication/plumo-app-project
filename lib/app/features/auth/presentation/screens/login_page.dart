// lib/app/features/auth/presentation/screens/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';
import 'package:plumo/app/features/auth/presentation/screens/signup_page.dart';

// (Import da nossa futura tela de cadastro)
// import 'package:plumo/app/features/auth/presentation/screens/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  // --- CORREÇÃO (Início) ---
  // A estrutura foi alterada para garantir que o 'context'
  // usado pelo ScaffoldMessenger seja filho do Scaffold.
  @override
  Widget build(BuildContext context) {
    // 1. O BlocConsumer agora é o widget pai
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          // 2. O 'listener' agora *não* mostra o SnackBar.
          // Por quê? O 'context' do listener é o context "antigo".
          // Vamos deixar o 'builder' lidar com isso.
          // (Poderíamos mostrar, mas a abordagem do builder é mais segura)
        }
      },
      // 3. O 'builder' agora é responsável por tudo.
      builder: (context, state) {
        final bool isLoading = state is AuthLoading;

        // 4. Esta é a mudança-chave: Usamos um 'Scaffold' aqui...
        return Scaffold(
          appBar: AppBar(title: const Text('Login - Plumo')),
          // 5. ...e um 'Builder' como corpo.
          // Este 'Builder' nos dá um *novo contexto* (scaffoldContext)
          // que é 100% GARANTIDO que é filho do Scaffold acima.
          body: Builder(
            builder: (scaffoldContext) {
              // 6. Verificamos o erro AQUI, dentro do novo contexto.
              if (state is AuthError) {
                // Usamos 'WidgetsBinding.instance.addPostFrameCallback'
                // para garantir que o SnackBar seja mostrado *depois*
                // que o frame (a tela) for construído.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3), // Dando tempo
                    ),
                  );
                });
              }

              // 7. O resto da UI (Stack, Form) é retornado normalmente.
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
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira sua senha';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            // 8. Usamos o 'context' original do builder para o 'onPressed'
                            onPressed: isLoading
                                ? null
                                : () => _onLoginPressed(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Entrar'),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    // NAVEGAÇÃO: Empurra a tela de SignUp
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpPage(),
                                      ),
                                    );
                                  },
                            child: const Text('Não tem uma conta? Cadastre-se'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading)
                    Container(
                      color: Colors.black.withAlpha(128), // Fundo escuro
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

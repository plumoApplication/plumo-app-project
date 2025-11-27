import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // Chama o método que cria a nova senha e desloga
      context.read<AuthCubit>().completePasswordReset(_passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redefinir Senha')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            // Se virar 'Unauthenticated', o AuthWrapper já nos tira daqui.
            // Mas podemos mostrar um SnackBar de sucesso antes.
            if (state is Unauthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Senha alterada! Faça login novamente.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 4),
                ),
              );

              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  // Volta para o Login (removendo a tela de Reset da pilha)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              });
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text('Crie uma nova senha para sua conta.'),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Nova Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mínimo 6 caracteres'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return 'Senhas não conferem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Salvar Nova Senha'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

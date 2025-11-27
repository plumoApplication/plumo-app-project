import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Agenda o Dialog para aparecer logo após a tela ser construída
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atenção Importante'),
        content: const Text(
          'Para redefinir sua senha, enviaremos um link para seu e-mail.\n\n'
          '⚠️ Você deve abrir este e-mail e clicar no link NO MESMO CELULAR onde o aplicativo está instalado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      // Chama o Cubit GLOBAL (que já está no app.dart)
      context.read<AuthCubit>().resetPassword(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos BlocConsumer para ouvir o resultado
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          // Limpa o estado de erro para não ficar preso
          context.read<AuthCubit>().resetState();
        }

        if (state is AuthPasswordResetSent) {
          // SUCESSO!
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link enviado! Verifique seu e-mail.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );

          // Reseta o estado e Volta para o Login
          context.read<AuthCubit>().resetState();
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Recuperar Senha')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Informe seu e-mail cadastrado para receber as instruções de redefinição.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty || !v.contains('@')) {
                        return 'Informe um e-mail válido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: isLoading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Enviar Link de Recuperação'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

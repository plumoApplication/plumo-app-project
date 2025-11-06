// lib/app/features/profile/presentation/screens/complete_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:plumo/app/features/profile/presentation/cubit/profile_state.dart';

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Fornecemos o 'ProfileCubit' (cérebro do formulário)
    //    para esta tela e seus filhos.
    return BlocProvider(
      create: (context) => sl<ProfileCubit>(),
      // 2. O 'BlocConsumer' escuta as mudanças do 'ProfileCubit'
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          // 3. Lógica do 'Listener' (o que fazer *depois* do estado mudar)

          if (state is ProfileError) {
            // Se der erro ao salvar, mostra SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is ProfileSaved) {
            // 4. SUCESSO! O Perfil foi salvo.
            // Agora, precisamos avisar o 'AuthCubit' (o "cérebro" principal)
            // para que ele verifique nosso status novamente.
            // Ao fazer isso, o AuthCubit emitirá 'Authenticated',
            // e o AuthWrapper nos navegará para a HomePage.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil salvo com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            // AVISA O AUTH_CUBIT (que está acima da árvore)
            context.read<AuthCubit>().checkAuthStatus();
          }
        },
        builder: (context, state) {
          // Se o estado for 'Carregando', definimos a flag
          final bool isLoading = state is ProfileLoading;

          // 5. Retorna o Scaffold com o formulário
          return Scaffold(
            appBar: AppBar(
              title: const Text('Complete seu Perfil'),
              automaticallyImplyLeading: false, // Esconde a flecha "Voltar"
            ),
            body: Stack(
              children: [
                // O Formulário
                _ProfileForm(
                  // Passamos o 'context' do BlocConsumer
                  // para o formulário poder chamar o Cubit
                  cubitContext: context,
                  isLoading: isLoading,
                ),
                // Camada de Loading
                if (isLoading)
                  Container(
                    color: Colors.black.withAlpha(128),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- Widget Interno (O Formulário) ---
// (Quebramos em um widget separado para melhor organização e
// para garantir que o 'GlobalKey<FormState>' funcione corretamente)

class _ProfileForm extends StatefulWidget {
  final BuildContext cubitContext;
  final bool isLoading;

  const _ProfileForm({required this.cubitContext, required this.isLoading});

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  // Chave do Formulário
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _fullNameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();

  // Máscaras
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _birthDateMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _fullNameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // Função chamada pelo botão "Salvar"
  void _onSavePressed() {
    // 1. Valida o formulário
    if (_formKey.currentState!.validate()) {
      // 2. Converte a data (string 'dd/MM/yyyy') para DateTime
      // (Esta é uma conversão simples, uma melhor usaria 'tryParse')
      final dateParts = _birthDateController.text.split('/');
      final birthDate = DateTime.parse(
        '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}',
      );

      // 3. Chama o 'ProfileCubit' (usando o context que recebemos)
      //    para salvar os dados.
      widget.cubitContext.read<ProfileCubit>().saveProfile(
        fullName: _fullNameController.text,
        cpf: _cpfMask.getUnmaskedText(), // Salva o CPF sem máscara
        phoneNumber: _phoneMask
            .getUnmaskedText(), // Salva o Celular sem máscara
        birthDate: birthDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Permite rolar a tela se o teclado cobrir os campos
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Precisamos de mais alguns dados para continuar.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Nome Completo
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),

            // CPF
            TextFormField(
              controller: _cpfController,
              inputFormatters: [_cpfMask],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'CPF',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null ||
                      value.length < 14) // 14 é o '###.###.###-##'
                  ? 'CPF inválido'
                  : null,
            ),
            const SizedBox(height: 16),

            // Celular
            TextFormField(
              controller: _phoneController,
              inputFormatters: [_phoneMask],
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Celular (com DDD)',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null ||
                      value.length < 15) // 15 é o '(##) #####-####'
                  ? 'Celular inválido'
                  : null,
            ),
            const SizedBox(height: 16),

            // Data de Nascimento
            TextFormField(
              controller: _birthDateController,
              inputFormatters: [_birthDateMask],
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Data de Nascimento (DD/MM/AAAA)',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.length < 10) ? 'Data inválida' : null,
            ),
            const SizedBox(height: 24),

            // Botão Salvar
            ElevatedButton(
              onPressed: widget.isLoading ? null : _onSavePressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Salvar e Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

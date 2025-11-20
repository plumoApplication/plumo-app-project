import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/profile/domain/entities/profile_entity.dart';
import 'package:plumo/app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:plumo/app/features/profile/presentation/cubit/profile_state.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatelessWidget {
  final ProfileEntity currentProfile;

  const EditProfilePage({super.key, required this.currentProfile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>(),
      child: _EditProfileView(currentProfile: currentProfile),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  final ProfileEntity currentProfile;

  const _EditProfileView({required this.currentProfile});

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _cpfController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;

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
  void initState() {
    super.initState();

    // Preenche Nome
    _nameController = TextEditingController(
      text: widget.currentProfile.fullName,
    );

    // --- CORREÇÃO DE FORMATAÇÃO (Passo 32.8) ---
    // Aplica a máscara nos dados "crus" vindos do banco
    final formattedCpf = _cpfMask.maskText(widget.currentProfile.cpf ?? '');
    _cpfController = TextEditingController(text: formattedCpf);
    // (Importante: Atualiza o estado interno da máscara para ela saber que já tem texto)
    _cpfMask.updateMask(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
      newValue: TextEditingValue(text: formattedCpf),
    );

    final formattedPhone = _phoneMask.maskText(
      widget.currentProfile.phoneNumber ?? '',
    );
    _phoneController = TextEditingController(text: formattedPhone);
    _phoneMask.updateMask(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      newValue: TextEditingValue(text: formattedPhone),
    );
    // ------------------------------------------

    // Formata a data
    String birthDateText = '';
    if (widget.currentProfile.birthDate != null) {
      birthDateText = DateFormat(
        'dd/MM/yyyy',
      ).format(widget.currentProfile.birthDate!);
    }
    _birthDateController = TextEditingController(text: birthDateText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      DateTime birthDate;
      try {
        final parts = _birthDateController.text.split('/');
        birthDate = DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}');
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data inválida')));
        return;
      }

      context.read<ProfileCubit>().saveProfile(
        fullName: _nameController.text,
        cpf: _cpfMask.getUnmaskedText(), // Salva limpo no banco
        phoneNumber: _phoneMask.getUnmaskedText(), // Salva limpo no banco
        birthDate: birthDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is ProfileSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final bool isLoading = state is ProfileLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Editar Perfil'),
            // (Removemos a action daqui)
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cpfController,
                    inputFormatters: [_cpfMask],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'CPF',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 14) ? 'Inválido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    inputFormatters: [_phoneMask],
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Celular',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 15) ? 'Inválido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthDateController,
                    inputFormatters: [_birthDateMask],
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: 'Data de Nascimento',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 10) ? 'Inválido' : null,
                  ),

                  const SizedBox(height: 32),

                  // --- BOTÃO SALVAR ADICIONADO ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Salvar Alterações'),
                    ),
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

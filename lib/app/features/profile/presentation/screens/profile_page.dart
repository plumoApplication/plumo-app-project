import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:plumo/app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:plumo/app/features/profile/presentation/cubit/profile_state.dart';
import 'package:plumo/app/features/profile/presentation/screens/edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Fornece o ProfileCubit e já carrega os dados
    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            final profile = state.profile;
            final isDriver = profile.role == 'driver';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- HEADER (Foto e Nome) ---
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                    //Mostrar foto real se profile.profilePictureUrl != null
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.fullName ?? 'Usuário sem nome',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(isDriver ? 'Motorista' : 'Passageiro'),
                    backgroundColor: isDriver
                        ? Colors.blue.shade100
                        : Colors.green.shade100,
                  ),

                  const SizedBox(height: 32),
                  const Divider(),

                  // --- MENU DE AÇÕES ---

                  // Opção: Editar Dados Pessoais
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editar Dados Pessoais'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfilePage(currentProfile: profile),
                        ),
                      );

                      if (result == true) {
                        // Recarrega o perfil para atualizar a tela
                        // (Precisamos usar o context.read DO CUBIT aqui)
                        if (context.mounted) {
                          context.read<ProfileCubit>().loadProfile();
                        }
                      }
                    },
                  ),

                  // --- SEÇÃO ESPECÍFICA DO MOTORISTA ---
                  if (isDriver) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: const Text('Meus Veículos'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        //Navegar para CRUD de Veículos
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veículos em breve...')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.badge),
                      title: const Text('Documentação'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        //Navegar para envio de CNH
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Documentação em breve...'),
                          ),
                        );
                      },
                    ),
                  ],

                  // ------------------------------------
                  const Divider(),

                  // Opção: Configurações
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Configurações'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),

                  const SizedBox(height: 40),

                  // --- BOTÃO DE LOGOUT ---
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Sair do App',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () {
                        // Chama o AuthCubit (que é global) para deslogar
                        context.read<AuthCubit>().signOut();
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Versão 1.0.0 (MVP)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Fallback
          return const Center(
            child: Text('Não foi possível carregar o perfil.'),
          );
        },
      ),
    );
  }
}

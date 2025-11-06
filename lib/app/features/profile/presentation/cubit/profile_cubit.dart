// lib/app/features/profile/presentation/cubit/profile_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/profile/domain/repositories/profile_repository.dart';
import 'package:plumo/app/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;

  ProfileCubit({required this.profileRepository}) : super(ProfileInitial());

  /// Método chamado pela UI quando o usuário clica em "Salvar Perfil"
  /// Agora ele recebe os campos de texto do formulário.
  Future<void> saveProfile({
    required String fullName,
    required String cpf,
    required String phoneNumber,
    required DateTime birthDate,
  }) async {
    // 1. Emite "Carregando"
    emit(ProfileLoading());

    // 2. Chama o repositório (que agora aceita os campos)
    final result = await profileRepository.updateProfile(
      fullName: fullName,
      cpf: cpf,
      phoneNumber: phoneNumber,
      birthDate: birthDate,
    );

    // 3. Processa o resultado
    result.fold(
      // 3a. Se deu 'Left' (Falha)
      (failure) => emit(ProfileError(message: failure.message)),
      // 3b. Se deu 'Right' (Sucesso)
      (_) => emit(ProfileSaved()),
    );
  }
}

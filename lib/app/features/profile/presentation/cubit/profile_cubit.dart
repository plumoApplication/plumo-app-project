import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/profile/domain/repositories/profile_repository.dart';
import 'package:plumo/app/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;

  ProfileCubit({required this.profileRepository}) : super(ProfileInitial());

  /// Busca os dados atuais do perfil
  Future<void> loadProfile() async {
    emit(ProfileLoading());

    final result = await profileRepository.getProfile();

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }
  // -------------------------

  Future<void> saveProfile({
    required String fullName,
    required String cpf,
    required String phoneNumber,
    required DateTime birthDate,
  }) async {
    emit(ProfileLoading());

    final result = await profileRepository.updateProfile(
      fullName: fullName,
      cpf: cpf,
      phoneNumber: phoneNumber,
      birthDate: birthDate,
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(ProfileSaved()),
    );
  }
}

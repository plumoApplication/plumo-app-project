import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/profile/data/models/profile_model.dart';

// Este é o contrato da camada de DADOS
// Ele define O QUE a nossa fonte de dados REMOTA (Supabase) deve fazer
// com a tabela 'profiles'.

abstract class ProfileRemoteDataSource {
  /// Busca o perfil do usuário logado na tabela 'profiles' do Supabase.
  /// Retorna um [ProfileModel] se o usuário for encontrado.
  ///
  /// Lança (throws) uma [ServerException] se ocorrer um erro na consulta
  /// ou se o perfil não for encontrado.
  Future<ProfileModel> getProfile();

  /// Atualiza (Update/Upsert) o perfil do usuário logado na
  /// tabela 'profiles' do Supabase.
  /// Recebe um [ProfileModel] com os novos dados.
  ///
  /// Lança (throws) uma [ServerException] se ocorrer um erro.
  Future<void> updateProfile({
    required String fullName,
    required String cpf,
    required String phoneNumber,
    required DateTime birthDate,
  });
}

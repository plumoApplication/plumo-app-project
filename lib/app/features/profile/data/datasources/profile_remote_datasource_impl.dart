// Usaremos o 'as supabase' para evitar o conflito de 'AuthException'
// (Embora não seja usado aqui, é uma boa prática manter)
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:plumo/app/features/profile/data/models/profile_model.dart';

// Esta é a IMPLEMENTAÇÃO do nosso DataSource de Perfil.
// É ela quem "suja as mãos" e chama o Supabase.

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  ProfileRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<ProfileModel> getProfile() async {
    try {
      // 1. Pega o ID do usuário atualmente logado
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        // Isso não deveria acontecer se o AuthWrapper estiver funcionando,
        // mas é uma proteção de segurança.
        throw ServerException(message: 'Usuário não autenticado.');
      }

      // 2. Faz a consulta (query) na tabela 'profiles'
      final response = await supabaseClient
          .from('profiles') // Nome da tabela
          .select() // Pega todas as colunas
          .eq('id', userId) // Onde o 'id' for igual ao do usuário logado
          .single(); // Espera UMA ÚNICA linha (ou lança erro se não achar)

      // 3. Converte o Map (JSON) retornado em nosso ProfileModel
      return ProfileModel.fromMap(response);
    } catch (e) {
      // 4. Se 'single()' falhar (ex: perfil não encontrado) ou
      //    qualquer outro erro de banco, lança nossa exceção.
      throw ServerException(message: 'Erro ao buscar perfil: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    required String cpf,
    required String phoneNumber,
    required DateTime birthDate,
  }) async {
    try {
      // 1. Pega o ID do usuário (precisamos saber *qual* linha atualizar)
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'Usuário não autenticado.');
      }

      // 2. Cria o 'Map' (JSON) apenas com os dados a serem atualizados.
      final profileMap = {
        'full_name': fullName,
        'cpf': cpf,
        'phone_number': phoneNumber,
        'birth_date': birthDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 3. Faz o 'update' na tabela 'profiles'
      await supabaseClient
          .from('profiles')
          .update(profileMap) // Os dados
          .eq('id', userId); // Onde o 'id' for igual ao do usuário
    } catch (e) {
      // 4. Se o update falhar
      throw ServerException(
        message: 'Erro ao atualizar perfil: ${e.toString()}',
      );
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/profile/domain/entities/profile_entity.dart';

// Este é o contrato do DOMÍNIO para a feature de Perfil.
// Ele define O QUE faremos, mas não COMO.

abstract class ProfileRepository {
  /// Busca os dados do perfil (nome, cpf, etc.) do usuário logado.
  /// Retorna uma [ProfileEntity] em caso de sucesso (Right).
  /// Retorna uma [Failure] (ex: ServerFailure) em caso de erro (Left).
  Future<Either<Failure, ProfileEntity>> getProfile();

  /// Atualiza os dados do perfil do usuário logado no banco de dados.
  /// Recebe uma [ProfileEntity] contendo os novos dados.
  /// Retorna [void] em caso de sucesso (Right).
  /// Retorna uma [Failure] (ex: ServerFailure) em caso de erro (Left).
  Future<Either<Failure, void>> updateProfile({
    required String fullName,
    required String cpf,
    required String phoneNumber,
    required DateTime birthDate,
    // (Podemos adicionar 'gender', 'pictureUrl' aqui no futuro)
  });
}

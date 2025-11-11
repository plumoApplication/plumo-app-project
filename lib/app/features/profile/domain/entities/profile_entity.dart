import 'package:equatable/equatable.dart';

// Esta é a nossa Entidade de Domínio.
// É um modelo Dart "limpo" que representa os dados da nossa tabela 'profiles'.
class ProfileEntity extends Equatable {
  final String id; // Chave primária (vem do auth.users)
  final String? fullName;
  final String? cpf;
  final DateTime? birthDate;
  final String? phoneNumber;
  final String? gender;
  final String? profilePictureUrl;
  final DateTime? updatedAt;
  final DateTime createdAt;
  final String? role;

  const ProfileEntity({
    required this.id,
    this.fullName,
    this.cpf,
    this.birthDate,
    this.phoneNumber,
    this.gender,
    this.profilePictureUrl,
    this.updatedAt,
    required this.createdAt,
    this.role,
  });

  /// VERIFICADOR DE PERFIL (Regra de Negócio)
  /// Define se o perfil do passageiro é considerado "completo".
  /// Para o MVP, exigimos Nome, CPF, Celular e Data de Nascimento.
  bool get isProfileComplete {
    return fullName != null &&
        cpf != null &&
        phoneNumber != null &&
        birthDate != null;
    // (Não vamos exigir gênero ou foto no cadastro inicial)
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    cpf,
    birthDate,
    phoneNumber,
    gender,
    profilePictureUrl,
    updatedAt,
    createdAt,
    role,
  ];
}

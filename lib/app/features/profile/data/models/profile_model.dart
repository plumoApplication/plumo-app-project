import 'package:plumo/app/features/profile/domain/entities/profile_entity.dart';

// O 'ProfileModel' é a nossa classe da camada de DADOS.
// Ela 'extends' (herda) a 'ProfileEntity' (camada de Domínio),
// então ela tem todos os campos (id, fullName, etc.) E
// a lógica (isProfileComplete).
//
// A principal função dela é adicionar os métodos fromMap/toMap (ou fromJson/toJson)
// para conversar com a API (Supabase).
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    super.fullName,
    super.cpf,
    super.birthDate,
    super.phoneNumber,
    super.gender,
    super.profilePictureUrl,
    super.updatedAt,
    required super.createdAt,
    super.role,
  });

  /// Construtor de fábrica: 'fromJson' (ou 'fromMap')
  /// Pega um 'Map' (o JSON) vindo do Supabase e o transforma em um 'ProfileModel'.
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      // Se o valor for 'null' no banco, ele permanece 'null' aqui
      fullName: map['full_name'] as String?,
      cpf: map['cpf'] as String?,
      birthDate: map['birth_date'] == null
          ? null
          : DateTime.parse(map['birth_date'] as String),
      phoneNumber: map['phone_number'] as String?,
      gender: map['gender'] as String?,
      profilePictureUrl: map['profile_picture_url'] as String?,
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      role: map['role'] as String?,
    );
  }

  /// Método 'toMap' (ou 'toJson')
  /// Pega o 'ProfileModel' e o transforma em um 'Map' (JSON)
  /// para enviar ao Supabase (ex: no 'updateProfile').
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'cpf': cpf,
      // Converte DateTime para string no formato ISO (que o Supabase entende)
      'birth_date': birthDate?.toIso8601String(),
      'phone_number': phoneNumber,
      'gender': gender,
      'profile_picture_url': profilePictureUrl,
      'updated_at': updatedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'role': role,
    };
  }
}

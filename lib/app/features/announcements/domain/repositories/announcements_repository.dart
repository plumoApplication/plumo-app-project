import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/announcements/data/models/announcement_model.dart';

abstract class AnnouncementsRepository {
  /// Busca a lista de avisos para um perfil específico ('passenger' ou 'driver')
  Future<Either<Failure, List<AnnouncementModel>>> getAnnouncements(
    String role,
  );
}

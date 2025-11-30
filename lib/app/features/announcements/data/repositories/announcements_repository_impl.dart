import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/announcements/data/datasources/announcements_remote_datasource.dart';
import 'package:plumo/app/features/announcements/data/models/announcement_model.dart';
import 'package:plumo/app/features/announcements/domain/repositories/announcements_repository.dart';

class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  final AnnouncementsRemoteDataSource remoteDataSource;

  AnnouncementsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AnnouncementModel>>> getAnnouncements(
    String role,
  ) async {
    try {
      final result = await remoteDataSource.getAnnouncements(role);
      return Right(result);
    } catch (e) {
      // Para avisos, se der erro, preferimos não quebrar a UI.
      // Podemos retornar uma lista vazia (falha silenciosa) ou o erro.
      // Vamos retornar o erro para o Cubit decidir (ele vai ignorar).
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

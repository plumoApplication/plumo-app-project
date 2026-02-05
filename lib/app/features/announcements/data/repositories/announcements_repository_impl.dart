import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/announcements/data/datasources/announcements_remote_datasource.dart';
import 'package:plumo/app/features/announcements/data/datasources/static_announcements_data.dart'; // Import dos Estáticos
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
      // 1. Tenta buscar no Supabase
      final remoteList = await remoteDataSource.getAnnouncements(role);

      // 2. Lógica de Prioridade:
      if (remoteList.isNotEmpty) {
        // Se tem avisos ATIVOS no banco, mostramos ELES.
        // Podemos concatenar com os estáticos se você quiser (remoteList + staticList)
        // Mas sua regra era "No Lugar De", então retornamos só o remoto.
        return Right(remoteList);
      } else {
        // Se o banco não tem nada ativo, mostramos os Estáticos.
        return Right(StaticAnnouncementsData.getDefaults(role));
      }
    } catch (e) {
      // 3. Fallback em caso de erro (sem internet, etc)
      // Em vez de mostrar erro na tela, mostramos os avisos estáticos (Fail Safe).
      return Right(StaticAnnouncementsData.getDefaults(role));
    }
  }
}

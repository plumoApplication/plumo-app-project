import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/driver_earnings/domain/entities/driver_earnings_entity.dart';

abstract class EarningsRepository {
  /// Busca os ganhos em um intervalo de datas específico
  Future<Either<Failure, DriverEarningsEntity>> getEarnings({
    required DateTime startDate,
    required DateTime endDate,
  });
}

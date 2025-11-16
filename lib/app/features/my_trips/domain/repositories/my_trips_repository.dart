import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';

// Contrato do Domínio: O que o app "faz"
abstract class MyTripsRepository {
  /// Busca a lista de reservas feitas pelo passageiro logado.
  Future<Either<Failure, List<BookingEntity>>> getMyTrips();
}

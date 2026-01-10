import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';

// Contrato do Domínio: O que o app "faz"
abstract class DriverTripsRepository {
  /// Busca a lista de viagens criadas pelo motorista logado.
  Future<Either<Failure, List<TripEntity>>> getMyTrips();
  Stream<void> getBookingStream();
}

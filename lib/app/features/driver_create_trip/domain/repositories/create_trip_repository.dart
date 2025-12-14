import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';

// Este é o contrato do DOMÍNIO.
// Ele define as regras de negócio "limpas".

abstract class CreateTripRepository {
  Future<Either<Failure, Unit>> createTrip(TripEntity trip);
}

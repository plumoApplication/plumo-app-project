import 'package:dartz/dartz.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

// Contrato do Domínio: O que o app "faz"
abstract class TripSearchRepository {
  /// Busca viagens públicas que correspondem aos critérios de busca.
  Future<Either<Failure, List<TripEntity>>> searchTrips({
    required Place origin,
    required Place destination,
    required DateTime date,
  });
}

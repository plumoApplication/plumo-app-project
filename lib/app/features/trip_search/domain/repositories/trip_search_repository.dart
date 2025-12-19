import 'package:dartz/dartz.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:plumo/app/core/errors/failures.dart';
import 'package:plumo/app/features/trip_search/domain/entities/trip_search_result_entity.dart'; // [NOVO IMPORT]

abstract class TripSearchRepository {
  /// Busca viagens ricas (com motorista e avaliações)
  Future<Either<Failure, List<TripSearchResultEntity>>> searchTrips({
    // [MUDANÇA DE TIPO]
    required Place origin,
    required Place destination,
    required DateTime date,
  });
}

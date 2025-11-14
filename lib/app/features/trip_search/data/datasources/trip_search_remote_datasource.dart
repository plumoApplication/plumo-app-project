import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

// Contrato dos Dados: O que o Supabase "faz"
abstract class TripSearchRemoteDataSource {
  /// Busca viagens no Supabase.
  /// Lança [ServerException] se a consulta falhar.
  Future<List<TripModel>> searchTrips({
    required Place origin,
    required Place destination,
    required DateTime date,
  });
}

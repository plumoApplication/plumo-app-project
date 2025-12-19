import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:plumo/app/features/trip_search/data/models/trip_search_result_model.dart'; // Importe o novo model

abstract class TripSearchRemoteDataSource {
  /// Busca viagens ricas (com dados do motorista) no Supabase via RPC.
  Future<List<TripSearchResultModel>> searchTrips({
    required Place origin,
    required Place destination,
    required DateTime date,
  });
}

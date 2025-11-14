import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';

// Contrato dos Dados: O que o Supabase "faz"
abstract class DriverTripsRemoteDataSource {
  /// Busca viagens e seus waypoints no Supabase
  /// onde o driver_id é o do usuário logado.
  /// Lança [ServerException] se a consulta falhar.
  Future<List<TripModel>> getMyTrips();
}

import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';

// Contrato dos Dados: O que o Supabase "faz"
abstract class DriverTripsRemoteDataSource {
  Future<List<TripModel>> getMyTrips();
  Stream<List<Map<String, dynamic>>> getBookingStream();
}

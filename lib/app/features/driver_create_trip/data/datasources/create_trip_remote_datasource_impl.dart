import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/driver_create_trip/data/datasources/create_trip_remote_datasource.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateTripRemoteDataSourceImpl implements CreateTripRemoteDataSource {
  final SupabaseClient supabaseClient;

  CreateTripRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<String> createTrip(TripModel trip) async {
    try {
      // O método toMap() do TripModel já está corrigido com as chaves certas
      final response = await supabaseClient
          .from('trips')
          .insert(trip.toMap())
          .select('id') // Retorna apenas o ID
          .single();

      return response['id'] as String;
    } catch (e) {
      throw ServerException(message: 'Erro ao criar viagem: $e');
    }
  }

  @override
  Future<void> createTripWaypoints(List<TripWaypointModel> waypoints) async {
    try {
      final List<Map<String, dynamic>> waypointsData = waypoints.map((wp) {
        return {
          'trip_id': wp.tripId, // O ID já deve vir preenchido pelo Repositório
          'order': wp.order,
          'place_name': wp.placeName,
          'place_google_id': wp.placeGoogleId,
          'latitude': wp.latitude,
          'longitude': wp.longitude,
          'price': wp.price,
          'boarding_place_name': wp.boardingPlaceName,
          'boarding_lat': wp.boardingLat,
          'boarding_lng': wp.boardingLng,
        };
      }).toList();

      await supabaseClient.from('trip_waypoints').insert(waypointsData);
    } catch (e) {
      throw ServerException(message: 'Erro ao criar pontos de parada: $e');
    }
  }
}

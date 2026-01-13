import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/booking/data/models/booking_model.dart';
import 'package:plumo/app/features/driver_trip_details/data/datasources/driver_trip_details_remote_datasource.dart';

class DriverTripDetailsRemoteDataSourceImpl
    implements DriverTripDetailsRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  DriverTripDetailsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<BookingModel>> getTripPassengers(String tripId) async {
    try {
      // Busca na tabela 'bookings'
      // JOIN: Traz os dados do perfil do passageiro (passenger:profiles!passenger_id)
      final response = await supabaseClient
          .from('bookings')
          .select('*, passenger:profiles!passenger_id(*)')
          .eq('trip_id', tripId)
          .order('created_at', ascending: true); // Ordem de chegada

      final List<BookingModel> bookings = response
          .map((map) => BookingModel.fromMap(map))
          .toList();

      return bookings;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar passageiros: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateTrip(TripEntity trip) async {
    try {
      // 1. Atualiza os dados da VIAGEM PRINCIPAL (Tabela 'trips')
      await supabaseClient
          .from('trips')
          .update({
            'departure_time': trip.departureTime.toIso8601String(),
            'price': trip.price, // Preço total
            'pickup_fee':
                trip.pickupFee, // Taxa de busca (Corrigido para snake_case)
            'boarding_place_name': trip.boardingPlaceName,
            'boarding_lat': trip.boardingLat,
            'boarding_lng': trip.boardingLng,
            // Adicione outros campos da trip que foram editados se houver
          })
          .eq('id', trip.id!);

      // 2. Atualiza CADA PONTO DE PARADA (Tabela 'trip_waypoints')
      if (trip.waypoints.isNotEmpty) {
        for (var wp in trip.waypoints) {
          // Só tentamos atualizar se o waypoint tiver um ID (ou seja, já existe no banco)
          if (wp.id != null) {
            await supabaseClient
                .from('trip_waypoints')
                .update({
                  'price': wp.price,
                  'place_name': wp.placeName,
                  'place_google_id': wp.placeGoogleId,
                  'latitude': wp.latitude,
                  'longitude': wp.longitude,
                  'boarding_place_name': wp.boardingPlaceName,
                  'boarding_lat': wp.boardingLat,
                  'boarding_lng': wp.boardingLng,
                  'order': wp.order,
                })
                .eq('id', wp.id!);
          }
        }
      }
    } catch (e) {
      throw ServerException(
        message: 'Erro ao atualizar dados da viagem: ${e.toString()}',
      );
    }
  }
}

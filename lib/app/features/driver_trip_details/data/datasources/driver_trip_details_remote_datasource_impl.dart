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
}

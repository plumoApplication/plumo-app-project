import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/booking/data/models/booking_model.dart';
import 'package:plumo/app/features/my_trips/data/datasources/my_trips_remote_datasource.dart';

// Esta é a IMPLEMENTAÇÃO do nosso DataSource (o "Trabalhador")

class MyTripsRemoteDataSourceImpl implements MyTripsRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  MyTripsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<BookingModel>> getMyTrips() async {
    try {
      final passengerId = supabaseClient.auth.currentUser?.id;
      if (passengerId == null) {
        throw ServerException(message: 'Usuário não autenticado.');
      }

      // 1. A consulta (query) é separada em 4 partes:
      final response = await supabaseClient
          .from('bookings')
          .select('*, trips(*, trip_waypoints(*))')
          .eq('passenger_id', passengerId)
          .order('created_at', ascending: false)
          .order(
            // 4. Ordena a tabela "NETA"
            'order',
            referencedTable: 'trips.trip_waypoints', // <-- CAMINHO CORRETO
            ascending: true,
          );

      final List<BookingModel> bookings = response
          .map((bookingMap) => BookingModel.fromMap(bookingMap))
          .toList();

      return bookings;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar suas reservas: ${e.toString()}',
      );
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:plumo/app/features/booking/data/models/booking_model.dart';

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  BookingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> createBooking(BookingModel booking) async {
    try {
      // CHAMADA RPC SEGURA
      final response = await supabaseClient.rpc(
        'request_booking',
        params: {
          'p_trip_id': booking.tripId,
          'p_passenger_id': booking.passengerId,
          'p_driver_id': booking.driverId,
          'p_origin_name': booking.originName,
          'p_destination_name': booking.destinationName,
          'p_seats': booking.seats,
          'p_total_price': booking.totalPrice,
          'p_pickup_lat': booking.pickupLat,
          'p_pickup_lng': booking.pickupLng,
          'p_pickup_address': booking.pickupAddress,
          'p_message': booking.message,
          'p_payment_method': booking.paymentMethod,
          'p_is_custom_pickup': booking.isCustomPickup,
        },
      );

      // O Supabase retorna um Map/JSON. Verificamos se houve erro lógico na function.
      if (response is Map && response['error'] != null) {
        throw ServerException(message: response['error']);
      }

      // Se sucesso, response['success'] será true.
    } on supabase.PostgrestException catch (e) {
      throw ServerException(message: 'Erro no banco de dados: ${e.message}');
    } catch (e) {
      throw ServerException(
        message: 'Erro inesperado ao criar reserva: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String newStatus,
  }) async {
    try {
      await supabaseClient
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', bookingId);
    } catch (e) {
      throw ServerException(
        message: 'Erro ao atualizar a reserva: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<BookingModel>> getDriverPendingBookings() async {
    try {
      final driverId = supabaseClient.auth.currentUser?.id;
      if (driverId == null) {
        throw ServerException(message: 'Usuário não autenticado.');
      }

      final response = await supabaseClient
          .from('bookings')
          .select(
            // Ajuste aqui se necessário, dependendo de como o Supabase mapeia FKs
            '*, trips(*), passenger:profiles!passenger_id(*), driver:profiles!driver_id(*)',
          )
          .eq('driver_id', driverId)
          .eq(
            'status',
            'pending',
          ) // ou 'pending', verifique o enum do seu banco
          .order('created_at', ascending: false);

      final List<BookingModel> bookings = (response as List)
          .map((map) => BookingModel.fromMap(map))
          .toList();

      return bookings;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar solicitações: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> cancelBooking(String bookingId) async {
    try {
      // 1. Executa o update na tabela 'bookings'
      await supabaseClient
          .from('bookings')
          .update({
            'status': 'cancelled',
            // Opcional: registrar data do cancelamento se tiver essa coluna
            // 'cancelled_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId); // Cláusula WHERE id = bookingId

      // 2. Se não der erro (exception), retornamos a mensagem de sucesso
      return "Solicitação cancelada com sucesso.";
    } catch (e) {
      // Tratamento de erro padrão
      throw ServerException(
        message: 'Erro ao cancelar reserva: ${e.toString()}',
      );
    }
  }
}

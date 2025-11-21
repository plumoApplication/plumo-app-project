import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:plumo/app/features/booking/data/models/booking_model.dart';

// Esta é a IMPLEMENTAÇÃO do nosso DataSource (o "Trabalhador")

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  BookingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> createBooking(BookingModel booking) async {
    try {
      // 1. Converte o Modelo em um Map
      final bookingMap = booking.toMap();

      // 2. Limpa os campos que o banco de dados deve gerar (ou que têm default)
      bookingMap.remove('id');
      bookingMap.remove('created_at');
      bookingMap.remove('status'); // Usa o default 'requested' do banco
      bookingMap.remove('payment_id'); // É nulo por padrão

      // 3. Faz o 'insert'
      // A nossa RLS (Script 2) garante que
      // bookingMap['passenger_id'] == auth.uid()
      await supabaseClient.from('bookings').insert(bookingMap);
    } catch (e) {
      // 4. Se o insert falhar (RLS, chave estrangeira, etc.)
      throw ServerException(
        message: 'Erro ao criar a reserva: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String newStatus,
  }) async {
    try {
      // 1. Faz o 'update'
      // A nossa RLS (Script 3) garante que apenas o
      // passageiro ou o motorista podem fazer isso.
      await supabaseClient
          .from('bookings')
          .update({'status': newStatus}) // Atualiza apenas o status
          .eq('id', bookingId); // Onde o ID da reserva corresponder
    } catch (e) {
      // 2. Se o update falhar
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

      // CONSULTA PODEROSA:
      // 1. Traz dados da Reserva (*)
      // 2. Traz dados da Viagem (trips) e seus Waypoints (aninhados)
      // 3. Traz dados do Passageiro (renomeado para 'passenger' via FK passenger_id)
      final response = await supabaseClient
          .from('bookings')
          .select(
            '*, trips(*, trip_waypoints(*)), passenger:profiles!passenger_id(*)',
          )
          .eq('driver_id', driverId) // Onde eu sou o motorista
          .eq('status', 'requested') // Apenas solicitadas (pendentes)
          .order('created_at', ascending: false);

      final List<BookingModel> bookings = response
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
      // Chama a função que criamos e fizemos deploy
      final response = await supabaseClient.functions.invoke(
        'cancel-booking',
        body: {'booking_id': bookingId},
      );

      final data = response.data;

      if (data == null || (data is Map && data['error'] != null)) {
        throw ServerException(
          message: data?['error'] ?? 'Erro desconhecido ao cancelar.',
        );
      }

      // Retorna a mensagem de sucesso (ex: "Cancelado com reembolso...")
      return data['message'] as String;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao processar cancelamento: ${e.toString()}',
      );
    }
  }
}

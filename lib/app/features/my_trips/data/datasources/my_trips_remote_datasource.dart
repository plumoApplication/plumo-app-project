import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/booking/data/models/booking_model.dart';

// Contrato dos Dados: O que o Supabase "faz"
abstract class MyTripsRemoteDataSource {
  /// Busca reservas no Supabase onde o passenger_id é o do usuário logado.
  /// Lança [ServerException] se a consulta falhar.
  Future<List<BookingModel>> getMyTrips();
}

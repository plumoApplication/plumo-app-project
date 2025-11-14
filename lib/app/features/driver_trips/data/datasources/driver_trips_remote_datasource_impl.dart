import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';
import 'package:plumo/app/features/driver_trips/data/datasources/driver_trips_remote_datasource.dart';

// Esta é a IMPLEMENTAÇÃO do nosso DataSource (o "Trabalhador")

class DriverTripsRemoteDataSourceImpl implements DriverTripsRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  DriverTripsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<TripModel>> getMyTrips() async {
    try {
      final driverId = supabaseClient.auth.currentUser?.id;
      if (driverId == null) {
        throw ServerException(message: 'Usuário não autenticado.');
      }

      // --- CORREÇÃO (Passo 19.11) ---

      // 1. A consulta (query) é separada em 3 partes:
      final response = await supabaseClient
          .from('trips')
          .select('*, trip_waypoints(*)') // 1. Seleciona as tabelas
          .eq('driver_id', driverId) // 2. Filtra pelo motorista
          .order(
            // 3. Ordena a tabela ANINHADA
            'order', // A coluna que queremos ordenar
            referencedTable: 'trip_waypoints', // A tabela aninhada
            ascending: true, // A direção
          );
      // --- FIM DA CORREÇÃO ---

      // 3. Converte a Lista de Maps em uma Lista de TripModels
      //    (Removendo o cast desnecessário que você apontou)
      final List<TripModel> trips = response
          .map((tripMap) => TripModel.fromMap(tripMap))
          .toList();

      return trips;
    } catch (e) {
      throw ServerException(
        message: 'Erro ao buscar suas viagens: ${e.toString()}',
      );
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/driver_create_trip/data/datasources/create_trip_remote_datasource.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';

// Esta é a IMPLEMENTAÇÃO do nosso DataSource (o "Trabalhador")

class CreateTripRemoteDataSourceImpl implements CreateTripRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  CreateTripRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<String> createTrip(TripModel trip) async {
    try {
      // 1. Pega o ID do usuário (para garantir que é o 'driver_id')
      final driverId = supabaseClient.auth.currentUser?.id;
      if (driverId == null) {
        throw ServerException(message: 'Usuário não autenticado.');
      }

      // 2. Prepara o 'Map' (JSON) para a tabela 'trips'
      //    (Note que não enviamos os 'waypoints' aqui)
      final tripMap = {
        'driver_id': driverId,
        'departure_time': trip.departureTime.toIso8601String(),
        'available_seats': trip.availableSeats,
        'status': trip.status, // (Virá como 'scheduled' do Cubit)
      };

      // 3. Faz o 'insert' e pede o 'id' de volta
      final response = await supabaseClient
          .from('trips')
          .insert(tripMap)
          .select('id') // Pede ao Supabase para retornar o 'id'
          .single(); // Espera um único resultado

      // 4. Retorna o ID da viagem recém-criada
      return response['id'] as String;
    } catch (e) {
      // 5. Se o insert falhar (ex: RLS bloqueou, dados errados)
      throw ServerException(message: 'Erro ao criar a viagem: ${e.toString()}');
    }
  }

  @override
  Future<void> createTripWaypoints(List<TripWaypointModel> waypoints) async {
    try {
      // 1. Converte a *lista* de Modelos em uma *lista* de Maps
      final List<Map<String, dynamic>> waypointsMaps = waypoints
          .map((wp) => wp.toMap())
          .toList();

      // 2. Remove 'id' e 'created_at' de cada map
      //    (O Supabase irá gerá-los)
      for (var map in waypointsMaps) {
        map.remove('id');
        map.remove('created_at');
      }

      // 3. Faz o 'insert' em LOTE (muito mais rápido)
      await supabaseClient.from('trip_waypoints').insert(waypointsMaps);
    } catch (e) {
      // 4. Se o insert em lote falhar
      throw ServerException(
        message: 'Erro ao salvar os pontos de parada: ${e.toString()}',
      );
    }
  }
}

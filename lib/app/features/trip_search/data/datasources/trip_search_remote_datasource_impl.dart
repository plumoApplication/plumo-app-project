import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';
import 'package:plumo/app/features/trip_search/data/datasources/trip_search_remote_datasource.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:intl/intl.dart'; // Precisamos formatar a data

class TripSearchRemoteDataSourceImpl implements TripSearchRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  TripSearchRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<TripModel>> searchTrips({
    required Place origin,
    required Place destination,
    required DateTime date,
  }) async {
    try {
      // 1. Prepara os parâmetros (sem alteração)
      final String originText = '%${origin.address}%';
      final String destinationText = '%${destination.address}%';
      final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // 2. A Chamada RPC (sem alteração)
      final rpcResponse = await supabaseClient.rpc(
        'search_trips',
        params: {
          'p_origin_name': originText,
          'p_destination_name': destinationText,
          'p_date': formattedDate,
        },
      );

      // --- CORREÇÃO DE TIPO (1) ---
      // Força a conversão de 'dynamic' (retorno da rpc) para a lista
      final List<dynamic> response = rpcResponse as List<dynamic>;
      // ---------------------------

      // 3. Viagens sem waypoints
      final List<TripModel> tripsWithoutWaypoints = response
          // Adiciona o cast explícito para cada item da lista
          .map((tripMap) => TripModel.fromMap(tripMap as Map<String, dynamic>))
          .toList();

      final List<String> tripIds = tripsWithoutWaypoints
          .map((t) => t.id!)
          .toList();

      if (tripIds.isEmpty) {
        return []; // Nenhuma viagem encontrada
      }

      // 4. Busca os Waypoints
      final waypointsRawResponse = await supabaseClient
          .from('trip_waypoints')
          .select('*')
          .inFilter('trip_id', tripIds)
          .order('order', ascending: true);

      // --- CORREÇÃO DE TIPO (2) ---
      // Força a conversão de 'dynamic' (retorno do select) para a lista
      final List<dynamic> waypointsResponse =
          waypointsRawResponse as List<dynamic>;
      // ---------------------------

      final List<Map<String, dynamic>> waypointsMaps = waypointsResponse
          .map((w) => w as Map<String, dynamic>)
          .toList();

      // 5. Combina os dados (sem alteração)
      final List<TripModel> finalTrips = [];
      for (var trip in tripsWithoutWaypoints) {
        final List<Map<String, dynamic>> matchingWaypointsMaps = waypointsMaps
            .where((w) => w['trip_id'] == trip.id)
            .toList();

        final List<TripWaypointModel> waypoints = matchingWaypointsMaps
            .map((waypointMap) => TripWaypointModel.fromMap(waypointMap))
            .toList();

        finalTrips.add(trip.copyWith(waypoints: waypoints));
      }

      return finalTrips;
    } catch (e) {
      // 6. Se a consulta falhar
      throw ServerException(message: 'Erro ao buscar viagens: ${e.toString()}');
    }
  }
}

import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';
import 'package:plumo/app/features/trip_search/data/datasources/trip_search_remote_datasource.dart';
import 'package:plumo/app/features/trip_search/data/models/trip_search_result_model.dart';

class TripSearchRemoteDataSourceImpl implements TripSearchRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  TripSearchRemoteDataSourceImpl({required this.supabaseClient});

  /// Método auxiliar privado para limpar o nome da cidade.
  String _cleanCityName(String? rawText) {
    if (rawText == null || rawText.isEmpty) return '';
    // 1. Pega o nome principal (Ex: "Natal, RN, Brasil" -> "Natal")
    String clean = rawText.split(',').first;
    // 2. Garante que não tem hífen (Ex: "João Pessoa - PB" -> "João Pessoa")
    clean = clean.split('-').first;
    // 3. Remove espaços em branco
    return clean.trim();
  }

  @override
  Future<List<TripSearchResultModel>> searchTrips({
    required Place origin,
    required Place destination,
    required DateTime date,
  }) async {
    try {
      // 1. Preparar Parâmetros
      final String originText = _cleanCityName(origin.name ?? origin.address);
      final String destinationText = _cleanCityName(
        destination.name ?? destination.address,
      );
      final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // 2. Chamada RPC
      final rpcResponse = await supabaseClient.rpc(
        'search_trips',
        params: {
          'search_origin_city': originText,
          'search_destination_city': destinationText,
          'search_date': formattedDate,
        },
      );

      final List<dynamic> responseList = rpcResponse as List<dynamic>;

      if (responseList.isEmpty) return [];

      // 3. Conversão Inicial
      final List<TripSearchResultModel> initialTrips = responseList
          .map(
            (data) =>
                TripSearchResultModel.fromMap(data as Map<String, dynamic>),
          )
          .toList();

      // 4. Buscar Waypoints
      final tripIds = initialTrips.map((e) => e.id).toList();

      final waypointsResponse = await supabaseClient
          .from('trip_waypoints')
          .select('*')
          .inFilter('trip_id', tripIds)
          .order('order', ascending: true);

      final List<dynamic> waypointsList = waypointsResponse as List<dynamic>;
      final waypointsMaps = waypointsList
          .map((e) => e as Map<String, dynamic>)
          .toList();

      // 5. Mesclar, Filtrar Duplicatas e CALCULAR PREÇO
      final List<TripSearchResultModel> completeTrips = [];

      final Set<String> processedTripIds = {};

      for (var trip in initialTrips) {
        // --- FILTRO DE DUPLICIDADE ---
        final String? currentId = trip.id;
        if (currentId == null || processedTripIds.contains(currentId)) {
          continue;
        }
        processedTripIds.add(currentId);
        // -----------------------------

        final myWaypointsData = waypointsMaps
            .where((w) => w['trip_id'] == currentId)
            .toList();

        final myWaypointsModels = myWaypointsData
            .map((w) => TripWaypointModel.fromMap(w))
            .toList();

        // Variáveis de Exibição
        String finalDisplayOrigin = trip.originName ?? '';
        String finalDisplayDest = trip.destinationName ?? '';

        // --- CÁLCULO DE PREÇO ---
        // Preço de "Onde ele entrou" (Start Cost)
        double startCost = 0.0;
        // Preço de "Onde ele vai sair" (End Cost)
        double endCost =
            trip.originalTotalPrice; // Assume total se for até o fim
        // ------------------------

        bool matches(String? databaseName, String searchText) {
          if (databaseName == null) return false;
          return databaseName.toLowerCase().contains(searchText.toLowerCase());
        }

        // 1. Descobrir Origem e Custo de Embarque
        if (matches(trip.originName, originText)) {
          // Se embarcou na Origem Inicial, o custo acumulado é 0
          startCost = 0.0;
        } else {
          // Se não, procura qual Waypoint é o embarque e pega o preço dele
          try {
            final wp = myWaypointsModels.firstWhere(
              (w) => matches(w.placeName, originText),
            );
            finalDisplayOrigin = wp.placeName;
            startCost = wp
                .price; // O preço no waypoint representa o custo da Origem até ali
          } catch (e) {
            // Se não achar, assume 0 por segurança
            startCost = 0.0;
          }
        }

        // 2. Descobrir Destino e Custo de Desembarque
        if (matches(trip.destinationName, destinationText)) {
          // Se foi até o destino final
          endCost = trip.originalTotalPrice;
        } else {
          // Se desceu num Waypoint
          try {
            final wp = myWaypointsModels.firstWhere(
              (w) => matches(w.placeName, destinationText),
            );
            finalDisplayDest = wp.placeName;
            endCost = wp.price;
          } catch (e) {
            // Se não achar, mantém o preço total
            endCost = trip.originalTotalPrice;
          }
        }

        // 3. Preço Final do Trecho
        double finalCalculatedPrice = endCost - startCost;

        // Tratamento de segurança para não ficar negativo (ex: erro de cadastro)
        if (finalCalculatedPrice < 0) finalCalculatedPrice = trip.price;

        completeTrips.add(
          trip.copyWithResult(
            waypoints: myWaypointsModels,
            displayOrigin: finalDisplayOrigin,
            displayDestination: finalDisplayDest,
            // Sobrescreve o preço com o valor calculado do trecho
            price: finalCalculatedPrice,
          ),
        );
      }

      return completeTrips;
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar viagens: $e');
    }
  }
}

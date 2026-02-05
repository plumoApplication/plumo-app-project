import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/trip_search/data/datasources/trip_search_remote_datasource.dart';
import 'package:plumo/app/features/trip_search/data/models/trip_search_result_model.dart';

class TripSearchRemoteDataSourceImpl implements TripSearchRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  TripSearchRemoteDataSourceImpl({required this.supabaseClient});

  /// Método auxiliar privado para limpar o nome da cidade.
  String _cleanCityName(String? rawText) {
    if (rawText == null || rawText.isEmpty) return '';
    String clean = rawText.split(',').first;
    clean = clean.split('-').first;
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

      // 2. Chamada RPC OTIMIZADA (Já traz waypoints e assentos reais)
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

      // 3. Processamento no Front-end (Cálculo de Preço Dinâmico)
      final List<TripSearchResultModel> completeTrips = [];
      final Set<String> processedTripIds = {};

      for (var tripMap in responseList) {
        // Converte o JSON que veio do banco para o nosso Model
        final trip = TripSearchResultModel.fromMap(
          tripMap as Map<String, dynamic>,
        );

        // Filtro de duplicidade (segurança extra)
        final String? currentId = trip.id;
        if (currentId == null || processedTripIds.contains(currentId)) {
          continue;
        }
        processedTripIds.add(currentId);

        // --- Lógica de Preço Dinâmico (Mantida) ---
        String finalDisplayOrigin = trip.originName ?? '';
        String finalDisplayDest = trip.destinationName ?? '';
        double startCost = 0.0;
        double endCost = trip.originalTotalPrice;

        // Recupera os waypoints que JÁ VIERAM da RPC (Sem nova chamada!)
        // O Model já converteu o JSON da RPC para List<TripWaypointModel>
        final waypoints = trip.waypoints;

        bool matches(String? databaseName, String searchText) {
          if (databaseName == null) return false;
          return databaseName.toLowerCase().contains(searchText.toLowerCase());
        }

        // 1. Calcular custo da Origem
        if (!matches(trip.originName, originText)) {
          try {
            // Como trip.waypoints é List<TripWaypointEntity>, fazemos o cast se necessário
            // Mas o TripSearchResultModel já garante que são Models internamente
            final wp = waypoints.firstWhere(
              (w) => matches(w.placeName, originText),
            );

            finalDisplayOrigin = wp.placeName;
            startCost = wp.price;
          } catch (_) {
            startCost = 0.0;
          }
        }

        // 2. Calcular custo do Destino
        if (!matches(trip.destinationName, destinationText)) {
          try {
            final wp = waypoints.firstWhere(
              (w) => matches(w.placeName, destinationText),
            );

            finalDisplayDest = wp.placeName;
            endCost = wp.price;
          } catch (_) {
            endCost = trip.originalTotalPrice;
          }
        }

        // 3. Preço Final
        double finalCalculatedPrice = endCost - startCost;
        if (finalCalculatedPrice < 0) finalCalculatedPrice = trip.price;

        // Adiciona à lista final
        completeTrips.add(
          trip.copyWithResult(
            displayOrigin: finalDisplayOrigin,
            displayDestination: finalDisplayDest,
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

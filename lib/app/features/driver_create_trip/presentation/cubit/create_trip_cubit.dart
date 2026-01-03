import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';
import 'package:plumo/app/features/driver_create_trip/domain/repositories/create_trip_repository.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateTripCubit extends Cubit<CreateTripState> {
  final CreateTripRepository repository;
  final _currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

  CreateTripCubit({required this.repository}) : super(const CreateTripState());

  // --- 1. DADOS BÁSICOS ---
  void updateBasicInfo({
    String? originName,
    LatLng? originCoords,
    String? destinationName,
    LatLng? destinationCoords,
    DateTime? date,
    DateTime? time,
    int? seats,
    double? price,
    double? pickupFee,
    String? originBoardingName,
    LatLng? originBoardingCoords,
  }) {
    emit(
      state.copyWith(
        originName: originName,
        originCoords: originCoords,
        destinationName: destinationName,
        destinationCoords: destinationCoords,
        departureDate: date,
        departureTime: time,
        availableSeats: seats,
        totalPrice: price,
        pickupFee: pickupFee,
        originBoardingName: originBoardingName,
        originBoardingCoords: originBoardingCoords,
      ),
    );
  }

  // --- 2. WAYPOINTS E VALIDAÇÃO DE PREÇO ---
  String? validateWaypointPrice(double price) {
    // Regra: Não pode ser maior que o total da viagem
    if (price >= state.totalPrice) {
      return 'O valor deve ser MENOR que o total da viagem (R\$ ${state.totalPrice})';
    }
    // Regra: Tem que ser maior que o ponto anterior (Preço Cumulativo)
    if (state.waypoints.isNotEmpty) {
      final lastPrice = state.waypoints.last.price;
      if (price <= lastPrice) {
        return 'O valor deve ser MAIOR que o ponto anterior (R\$ $lastPrice)';
      }
    }
    return null;
  }

  void addWaypoint(TripWaypointModel waypoint) {
    final error = validateWaypointPrice(waypoint.price);
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return;
    }
    final newList = List<TripWaypointModel>.from(state.waypoints)
      ..add(waypoint);
    emit(state.copyWith(waypoints: newList));
  }

  void removeWaypoint(int index) {
    final newList = List<TripWaypointModel>.from(state.waypoints)
      ..removeAt(index);
    emit(state.copyWith(waypoints: newList));
  }

  // --- 3. NAVEGAÇÃO E CÁLCULO ---
  void nextStep() {
    if (state.currentStep == CreateTripStep.basicInfo) {
      final missingOrigin = state.originCoords == null;
      final missingDest = state.destinationCoords == null;
      final missingDate =
          state.finalDepartureDateTime == null; // Cobre Data e Hora
      final missingSeats = state.availableSeats <= 0;
      final missingPrice = state.totalPrice <= 0;
      final missingBoarding =
          state.originBoardingName == null ||
          state.originBoardingName!.trim().isEmpty;
      if (missingOrigin ||
          missingDest ||
          missingDate ||
          missingSeats ||
          missingPrice ||
          missingBoarding) {
        emit(state.copyWith(errorMessage: 'Preencha os dados obrigatórios'));
        return;
      }
      emit(state.copyWith(currentStep: CreateTripStep.waypoints));
    } else if (state.currentStep == CreateTripStep.waypoints) {
      emit(state.copyWith(currentStep: CreateTripStep.review));
    }
  }

  void previousStep() {
    if (state.currentStep == CreateTripStep.review) {
      emit(state.copyWith(currentStep: CreateTripStep.waypoints));
    } else if (state.currentStep == CreateTripStep.waypoints) {
      emit(state.copyWith(currentStep: CreateTripStep.basicInfo));
    }
  }

  // Lógica de Exibição dos Segmentos (A->B, B->C)
  List<String> calculateSegmentsSummary() {
    final List<String> summary = [];

    // A -> Waypoints
    for (var wp in state.waypoints) {
      summary.add(
        'Origem ➝ ${wp.placeName}: ${_currencyFormat.format(wp.price)}',
      );
    }
    // A -> Destino
    summary.add('Origem ➝ Destino:${_currencyFormat.format(state.totalPrice)}');

    // Entre Waypoints (Cálculo da Diferença)
    for (int i = 0; i < state.waypoints.length; i++) {
      final startWp = state.waypoints[i];

      // Waypoint -> Próximos Waypoints
      for (int j = i + 1; j < state.waypoints.length; j++) {
        final endWp = state.waypoints[j];
        final diff = endWp.price - startWp.price;
        summary.add(
          '${startWp.placeName} ➝ ${endWp.placeName}: ${_currencyFormat.format(diff)}',
        );
      }

      // Waypoint -> Destino Final
      final diffToFinal = state.totalPrice - startWp.price;
      summary.add(
        '${startWp.placeName} ➝ Destino: ${_currencyFormat.format(diffToFinal)}',
      );
    }
    return summary;
  }

  // --- 4. ENVIO FINAL (Correção Crítica) ---
  Future<void> submitTrip() async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não logado');

      // VALIDAÇÃO CRÍTICA DE DADOS
      if (state.originName == null || state.destinationName == null) {
        throw Exception("Origem ou Destino não preenchidos.");
      }

      final newTrip = TripModel(
        driverId: userId,
        // Garanta que estamos usando as variáveis do STATE
        originName: state.originName,
        originLat: state.originCoords?.latitude,
        originLng: state.originCoords?.longitude,

        destinationName: state.destinationName,
        destinationLat: state.destinationCoords?.latitude,
        destinationLng: state.destinationCoords?.longitude,

        departureTime: state.finalDepartureDateTime!,
        availableSeats: state.availableSeats,
        status: 'scheduled',
        price: state.totalPrice,

        // Novos Campos
        pickupFee: state.pickupFee,
        boardingPlaceName: state.originBoardingName,
        boardingLat: state.originBoardingCoords?.latitude,
        boardingLng: state.originBoardingCoords?.longitude,

        waypoints: state.waypoints,
        createdAt: DateTime.now(),
      );

      // Chama o repositório que acabamos de corrigir
      final result = await repository.createTrip(newTrip);

      result.fold(
        (failure) => emit(
          state.copyWith(isLoading: false, errorMessage: failure.message),
        ),
        (success) => emit(state.copyWith(isLoading: false, isSuccess: true)),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  // --- MÉTODOS DE LIMPEZA ---
  void reset() => emit(const CreateTripState());

  void clearOrigin() {
    emit(state.copyWith(clearOrigin: true));
  }

  void clearDestination() {
    emit(state.copyWith(clearDestination: true));
  }
}

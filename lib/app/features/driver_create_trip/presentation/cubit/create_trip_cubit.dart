import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_model.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';
import 'package:plumo/app/features/driver_create_trip/domain/repositories/create_trip_repository.dart';
import 'package:plumo/app/features/driver_create_trip/presentation/cubit/create_trip_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Para pegar o ID do user

class CreateTripCubit extends Cubit<CreateTripState> {
  final CreateTripRepository repository;

  CreateTripCubit({required this.repository}) : super(const CreateTripState());

  // --- PASSO 1: DADOS BÁSICOS ---

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

  // --- PASSO 2: WAYPOINTS (Com Validação de Preço) ---

  String? validateWaypointPrice(double price) {
    // Regra 1: Preço não pode ser maior ou igual ao total da viagem
    if (price >= state.totalPrice) {
      return 'O valor deve ser MENOR que o total da viagem (R\$ ${state.totalPrice})';
    }

    // Regra 2: Preço não pode ser menor que o ponto anterior (se houver)
    if (state.waypoints.isNotEmpty) {
      final lastPrice = state.waypoints.last.price;
      if (price <= lastPrice) {
        return 'O valor deve ser MAIOR que o ponto anterior (R\$ $lastPrice)';
      }
    }

    return null; // Válido
  }

  void addWaypoint(TripWaypointModel waypoint) {
    // Validação extra de segurança
    final error = validateWaypointPrice(waypoint.price);
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return;
    }

    // Adiciona na lista
    final newList = List<TripWaypointModel>.from(state.waypoints)
      ..add(waypoint);
    emit(state.copyWith(waypoints: newList));
  }

  void removeWaypoint(int index) {
    final newList = List<TripWaypointModel>.from(state.waypoints)
      ..removeAt(index);
    emit(state.copyWith(waypoints: newList));
  }

  // --- NAVEGAÇÃO ENTRE PASSOS ---

  void nextStep() {
    if (state.currentStep == CreateTripStep.basicInfo) {
      // Validação do Passo 1
      if (state.originCoords == null ||
          state.destinationCoords == null ||
          state.finalDepartureDateTime == null ||
          state.totalPrice <= 0) {
        emit(
          state.copyWith(
            errorMessage: 'Preencha todos os campos obrigatórios.',
          ),
        );
        return;
      }
      emit(state.copyWith(currentStep: CreateTripStep.waypoints));
    } else if (state.currentStep == CreateTripStep.waypoints) {
      // Vai para Revisão
      emit(state.copyWith(currentStep: CreateTripStep.review));
    }
  }

  void previousStep() {
    if (state.currentStep == CreateTripStep.waypoints) {
      emit(state.copyWith(currentStep: CreateTripStep.basicInfo));
    } else if (state.currentStep == CreateTripStep.review) {
      emit(state.copyWith(currentStep: CreateTripStep.waypoints));
    }
  }

  // --- CÁLCULO DE SEGMENTOS (Para exibir na tela de Revisão) ---
  List<String> calculateSegmentsSummary() {
    final List<String> summary = [];

    // Lista completa de pontos: Origem -> W1 -> W2 -> ... -> Destino
    // Vamos representar apenas com Nomes e Preços Acumulados
    // Origem: Preço 0
    // W1: Preço X
    // Destino: Preço Total

    // Como o usuário pediu: mostrar A->B, B->C, etc.
    // Vamos iterar

    // 1. Segmentos da Origem (A) para todos os pontos
    for (var wp in state.waypoints) {
      summary.add(
        'Origem ➝ ${wp.placeName}: R\$ ${wp.price.toStringAsFixed(2)}',
      );
    }
    summary.add('Origem ➝ Destino: R\$ ${state.totalPrice.toStringAsFixed(2)}');

    // 2. Segmentos entre pontos intermediários
    for (int i = 0; i < state.waypoints.length; i++) {
      final startWp = state.waypoints[i];

      // Do ponto atual para os próximos pontos
      for (int j = i + 1; j < state.waypoints.length; j++) {
        final endWp = state.waypoints[j];
        final diff = endWp.price - startWp.price;
        summary.add(
          '${startWp.placeName} ➝ ${endWp.placeName}: R\$ ${diff.toStringAsFixed(2)}',
        );
      }

      // Do ponto atual para o Destino Final
      final diffToFinal = state.totalPrice - startWp.price;
      summary.add(
        '${startWp.placeName} ➝ Destino: R\$ ${diffToFinal.toStringAsFixed(2)}',
      );
    }

    return summary;
  }

  // --- FINALIZAÇÃO ---

  Future<void> submitTrip() async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não logado');

      final newTrip = TripModel(
        driverId: userId,
        departureTime: state.finalDepartureDateTime!,
        availableSeats: state.availableSeats,
        status: 'scheduled',
        originName: state.originName!,
        originLat: state.originCoords!.latitude,
        originLng: state.originCoords!.longitude,
        destinationName: state.destinationName!,
        destinationLat: state.destinationCoords!.latitude,
        destinationLng: state.destinationCoords!.longitude,

        // Novos Campos
        pickupFee: state.pickupFee,
        boardingPlaceName: state.originBoardingName,
        boardingLat: state.originBoardingCoords?.latitude,
        boardingLng: state.originBoardingCoords?.longitude,

        waypoints: state.waypoints, // A lista já está preenchida

        createdAt: DateTime.now(),
      );

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

  // Reseta para criar nova viagem
  void reset() {
    emit(const CreateTripState());
  }
}

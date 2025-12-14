import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/driver_create_trip/data/models/trip_waypoint_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum CreateTripStep { basicInfo, waypoints, review }

class CreateTripState extends Equatable {
  final CreateTripStep currentStep;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  // --- DADOS TEMPORÁRIOS DA VIAGEM ---
  // Origem
  final String? originName;
  final LatLng? originCoords;

  // Destino
  final String? destinationName;
  final LatLng? destinationCoords;

  // Detalhes
  final DateTime? departureDate;
  final DateTime? departureTime; // Apenas para guardar a hora
  final int availableSeats;
  final double totalPrice; // Valor A -> D
  final double pickupFee; // Taxa de busca específica

  // Local de Embarque (Origem)
  final String? originBoardingName;
  final LatLng? originBoardingCoords;

  // Lista de Paradas
  final List<TripWaypointModel> waypoints;

  const CreateTripState({
    this.currentStep = CreateTripStep.basicInfo,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.originName,
    this.originCoords,
    this.destinationName,
    this.destinationCoords,
    this.departureDate,
    this.departureTime,
    this.availableSeats = 4, // Default
    this.totalPrice = 0.0,
    this.pickupFee = 0.0,
    this.originBoardingName,
    this.originBoardingCoords,
    this.waypoints = const [],
  });

  // Método auxiliar para combinar Data + Hora em um único DateTime
  DateTime? get finalDepartureDateTime {
    if (departureDate == null || departureTime == null) return null;
    return DateTime(
      departureDate!.year,
      departureDate!.month,
      departureDate!.day,
      departureTime!.hour,
      departureTime!.minute,
    );
  }

  CreateTripState copyWith({
    CreateTripStep? currentStep,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    String? originName,
    LatLng? originCoords,
    String? destinationName,
    LatLng? destinationCoords,
    DateTime? departureDate,
    DateTime? departureTime,
    int? availableSeats,
    double? totalPrice,
    double? pickupFee,
    String? originBoardingName,
    LatLng? originBoardingCoords,
    List<TripWaypointModel>? waypoints,
    // --- FLAGS DE LIMPEZA ---
    bool clearOrigin = false,
    bool clearDestination = false,
  }) {
    return CreateTripState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Limpa o erro ao mudar estado
      isSuccess: isSuccess ?? this.isSuccess,

      // Lógica: Se clearOrigin for true, define como null.
      // Caso contrário, tenta usar o novo valor (originName) ou mantém o antigo (this.originName).
      originName: clearOrigin ? null : (originName ?? this.originName),
      originCoords: clearOrigin ? null : (originCoords ?? this.originCoords),
      destinationName: clearDestination
          ? null
          : (destinationName ?? this.destinationName),
      destinationCoords: clearDestination
          ? null
          : (destinationCoords ?? this.destinationCoords),

      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      totalPrice: totalPrice ?? this.totalPrice,
      pickupFee: pickupFee ?? this.pickupFee,
      originBoardingName: originBoardingName ?? this.originBoardingName,
      originBoardingCoords: originBoardingCoords ?? this.originBoardingCoords,
      waypoints: waypoints ?? this.waypoints,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    isLoading,
    errorMessage,
    isSuccess,
    originName,
    originCoords,
    destinationName,
    destinationCoords,
    departureDate,
    departureTime,
    availableSeats,
    totalPrice,
    pickupFee,
    originBoardingName,
    originBoardingCoords,
    waypoints,
  ];
}

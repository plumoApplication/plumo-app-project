import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';
import 'package:plumo/app/features/driver_create_trip/domain/entities/trip_entity.dart';

// Classe base
abstract class DriverTripsState extends Equatable {
  const DriverTripsState();
  @override
  List<Object> get props => [];
}

/// Estado Inicial/Carregando: A tela está buscando as viagens.
class DriverTripsLoading extends DriverTripsState {}

/// Estado de Sucesso: As viagens foram buscadas
/// (mesmo que a lista esteja vazia).
class DriverTripsSuccess extends DriverTripsState {
  final List<TripEntity> trips;
  final List<BookingEntity> pendingRequests;

  const DriverTripsSuccess({
    required this.trips,
    required this.pendingRequests,
  });

  @override
  List<Object> get props => [trips];
}

/// Estado de Erro: A busca falhou.
class DriverTripsError extends DriverTripsState {
  final String message;
  const DriverTripsError({required this.message});
  @override
  List<Object> get props => [message];
}

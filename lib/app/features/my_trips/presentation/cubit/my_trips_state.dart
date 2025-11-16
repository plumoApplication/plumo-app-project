import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';

// Classe base
abstract class MyTripsState extends Equatable {
  const MyTripsState();
  @override
  List<Object> get props => [];
}

/// Estado Inicial/Carregando: A tela está buscando as reservas.
class MyTripsLoading extends MyTripsState {}

/// Estado de Sucesso: As reservas foram buscadas
/// (mesmo que a lista esteja vazia).
class MyTripsSuccess extends MyTripsState {
  final List<BookingEntity> bookings;

  const MyTripsSuccess({required this.bookings});

  @override
  List<Object> get props => [bookings];
}

/// Estado de Erro: A busca falhou.
class MyTripsError extends MyTripsState {
  final String message;
  const MyTripsError({required this.message});
  @override
  List<Object> get props => [message];
}

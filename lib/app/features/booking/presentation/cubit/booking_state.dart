import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/booking/domain/entities/booking_entity.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial (antes de qualquer ação)
class BookingInitial extends BookingState {}

/// Estado de carregamento (Spinner/Loading)
class BookingLoading extends BookingState {}

/// Sucesso genérico (ex: Reserva criada com sucesso)
class BookingSuccess extends BookingState {}

/// Erro genérico (ex: Falha na conexão)
class BookingError extends BookingState {
  final String message;

  const BookingError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Quando o motorista busca reservas, mas não há nenhuma pendente
class BookingEmpty extends BookingState {}

/// Quando o motorista carrega a lista de reservas pendentes com sucesso
class DriverBookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  const DriverBookingsLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

/// Quando uma reserva é cancelada com sucesso (feedback para o usuário)
class BookingCancelled extends BookingState {
  final String message;

  const BookingCancelled({required this.message});

  @override
  List<Object?> get props => [message];
}

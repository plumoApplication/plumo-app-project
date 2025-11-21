import 'package:equatable/equatable.dart';
import 'package:plumo/app/features/driver_earnings/domain/entities/driver_earnings_entity.dart';

// Enum para identificar qual filtro está ativo na UI
enum EarningsFilter { today, weekly, monthly, custom }

abstract class DriverEarningsState extends Equatable {
  const DriverEarningsState();
  @override
  List<Object?> get props => [];
}

class DriverEarningsInitial extends DriverEarningsState {}

class DriverEarningsLoading extends DriverEarningsState {
  // Mantemos o filtro atual para a UI não "piscar" o botão errado
  final EarningsFilter currentFilter;
  const DriverEarningsLoading({required this.currentFilter});
}

class DriverEarningsLoaded extends DriverEarningsState {
  final DriverEarningsEntity earnings;
  final EarningsFilter currentFilter;
  // Se for customizado, guardamos as datas para exibir na tela
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const DriverEarningsLoaded({
    required this.earnings,
    required this.currentFilter,
    this.customStartDate,
    this.customEndDate,
  });

  @override
  List<Object?> get props => [
    earnings,
    currentFilter,
    customStartDate,
    customEndDate,
  ];
}

class DriverEarningsError extends DriverEarningsState {
  final String message;
  const DriverEarningsError({required this.message});
  @override
  List<Object> get props => [message];
}

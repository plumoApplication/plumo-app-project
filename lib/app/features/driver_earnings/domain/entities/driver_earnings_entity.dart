import 'package:equatable/equatable.dart';

class DriverEarningsEntity extends Equatable {
  final double totalEarnings;
  final int totalRides;
  final int totalCancelledRides;
  final double averageRating;
  final List<EarningTransactionEntity> recentTransactions; // Extrato

  const DriverEarningsEntity({
    required this.totalEarnings,
    required this.totalRides,
    required this.totalCancelledRides,
    required this.averageRating,
    this.recentTransactions = const [],
  });

  @override
  List<Object?> get props => [
    totalEarnings,
    totalRides,
    totalCancelledRides,
    averageRating,
    recentTransactions,
  ];
}

class EarningTransactionEntity extends Equatable {
  final String id;
  final DateTime date;
  final double amount;
  final String type; // 'ride', 'bonus', 'tip'
  final String description;

  const EarningTransactionEntity({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
  });

  @override
  List<Object?> get props => [id, date, amount, type, description];
}

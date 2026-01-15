import 'package:plumo/app/features/driver_earnings/domain/entities/driver_earnings_entity.dart';

class DriverEarningsModel extends DriverEarningsEntity {
  const DriverEarningsModel({
    required super.totalEarnings,
    required super.totalRides,
    required super.totalCancelledRides,
    required super.averageRating,
    required super.recentTransactions,
  });

  factory DriverEarningsModel.fromMap(Map<String, dynamic> map) {
    // Parsing seguro para números (Postgres pode mandar int ou double)
    final earnings = map['earnings'] != null
        ? (map['earnings'] as num).toDouble()
        : 0.0;

    final rides = map['rides'] != null ? (map['rides'] as num).toInt() : 0;

    final cancelled = map['cancelled_rides'] != null
        ? (map['cancelled_rides'] as num).toInt()
        : 0;
    final rating = map['rating'] != null
        ? (map['rating'] as num).toDouble()
        : 0.0;

    // Se o RPC retornar uma lista de transactions no futuro
    final List<EarningTransactionEntity> transactions = [];
    if (map['history'] != null) {
      for (var item in (map['history'] as List)) {
        transactions.add(EarningTransactionModel.fromMap(item));
      }
    }

    return DriverEarningsModel(
      totalEarnings: earnings,
      totalRides: rides,
      totalCancelledRides: cancelled,
      averageRating: rating,
      recentTransactions: transactions,
    );
  }
}

class EarningTransactionModel extends EarningTransactionEntity {
  const EarningTransactionModel({
    required super.id,
    required super.date,
    required super.amount,
    required super.type,
    required super.description,
  });

  factory EarningTransactionModel.fromMap(Map<String, dynamic> map) {
    return EarningTransactionModel(
      id: map['id'] ?? '',
      date: DateTime.parse(map['created_at']),
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] ?? 'ride',
      description: map['description'] ?? 'Corrida finalizada',
    );
  }
}

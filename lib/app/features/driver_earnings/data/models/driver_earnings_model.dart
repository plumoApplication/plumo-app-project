import 'package:plumo/app/features/driver_earnings/domain/entities/driver_earnings_entity.dart';

class DriverEarningsModel extends DriverEarningsEntity {
  const DriverEarningsModel({
    required super.totalEarnings,
    required super.totalRides,
  });

  factory DriverEarningsModel.fromMap(Map<String, dynamic> map) {
    return DriverEarningsModel(
      // O Supabase retorna 'numeric' que pode vir como int ou double
      totalEarnings: double.parse(map['earnings'].toString()),
      totalRides: map['rides'] as int,
    );
  }
}

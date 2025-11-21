import 'package:equatable/equatable.dart';

class DriverEarningsEntity extends Equatable {
  final double totalEarnings;
  final int totalRides;

  const DriverEarningsEntity({
    required this.totalEarnings,
    required this.totalRides,
  });

  @override
  List<Object?> get props => [totalEarnings, totalRides];
}

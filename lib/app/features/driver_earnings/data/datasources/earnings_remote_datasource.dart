import 'package:plumo/app/features/driver_earnings/data/models/driver_earnings_model.dart';

abstract class EarningsRemoteDataSource {
  /// Chama a RPC 'get_driver_earnings' no Supabase
  Future<DriverEarningsModel> getEarnings({
    required DateTime startDate,
    required DateTime endDate,
  });
}

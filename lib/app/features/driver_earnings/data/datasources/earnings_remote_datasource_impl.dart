import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:plumo/app/core/errors/exceptions.dart';
import 'package:plumo/app/features/driver_earnings/data/datasources/earnings_remote_datasource.dart';
import 'package:plumo/app/features/driver_earnings/data/models/driver_earnings_model.dart';

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  EarningsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<DriverEarningsModel> getEarnings({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Chama a RPC (Função de Banco de Dados)
      final response = await supabaseClient.rpc(
        'get_driver_earnings',
        params: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      // O retorno é um Map/JSON simples { "earnings": X, "rides": Y }
      // Precisamos garantir o cast para Map, pois rpc retorna dynamic
      final data = response as Map<String, dynamic>;

      return DriverEarningsModel.fromMap(data);
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar ganhos: ${e.toString()}');
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/driver_earnings/domain/repositories/earnings_repository.dart';
import 'package:plumo/app/features/driver_earnings/presentation/cubit/driver_earnings_state.dart';

class DriverEarningsCubit extends Cubit<DriverEarningsState> {
  final EarningsRepository earningsRepository;

  DriverEarningsCubit({required this.earningsRepository})
    : super(DriverEarningsInitial());

  /// Carrega os ganhos com base no filtro pré-definido
  Future<void> loadEarnings(EarningsFilter filter) async {
    emit(DriverEarningsLoading(currentFilter: filter));

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    // Lógica de Cálculo de Datas
    switch (filter) {
      case EarningsFilter.today:
        // Começo de hoje (00:00) até agora (ou fim do dia)
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case EarningsFilter.weekly:
        // Pega o primeiro dia da semana (Segunda-feira = 1)
        // Subtrai dias para chegar na segunda-feira
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        ); // Zera hora
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;

      case EarningsFilter.monthly:
        // Dia 1 do mês atual
        startDate = DateTime(now.year, now.month, 1);
        // Último dia do mês (dia 0 do próximo mês)
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;

      case EarningsFilter.custom:
        // Se chamar sem datas, usa hoje como fallback
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
    }

    await _fetchData(startDate, endDate, filter);
  }

  /// Carrega ganhos com datas específicas (Filtro Customizado)
  Future<void> loadCustomEarnings(DateTime start, DateTime end) async {
    emit(const DriverEarningsLoading(currentFilter: EarningsFilter.custom));

    // Ajusta as horas para cobrir o dia todo
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    await _fetchData(startDate, endDate, EarningsFilter.custom);
  }

  Future<void> _fetchData(
    DateTime start,
    DateTime end,
    EarningsFilter filter,
  ) async {
    final result = await earningsRepository.getEarnings(
      startDate: start,
      endDate: end,
    );

    result.fold(
      (failure) => emit(DriverEarningsError(message: failure.message)),
      (earnings) => emit(
        DriverEarningsLoaded(
          earnings: earnings,
          currentFilter: filter,
          customStartDate: start,
          customEndDate: end,
        ),
      ),
    );
  }
}

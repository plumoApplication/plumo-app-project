import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/driver_earnings/presentation/cubit/driver_earnings_cubit.dart';
import 'package:plumo/app/features/driver_earnings/presentation/cubit/driver_earnings_state.dart';

class DriverEarningsPage extends StatelessWidget {
  const DriverEarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Carrega "Hoje" por padrão ao abrir
      create: (context) =>
          sl<DriverEarningsCubit>()..loadEarnings(EarningsFilter.today),
      child: const _DriverEarningsView(),
    );
  }
}

class _DriverEarningsView extends StatefulWidget {
  const _DriverEarningsView();

  @override
  State<_DriverEarningsView> createState() => _DriverEarningsViewState();
}

class _DriverEarningsViewState extends State<_DriverEarningsView> {
  // Função para abrir o seletor de intervalo de datas
  Future<void> _selectCustomRange(BuildContext context) async {
    // 1. Captura o Cubit antes (Segurança)
    final cubit = context.read<DriverEarningsCubit>();

    final now = DateTime.now();
    // Margem de segurança para evitar erro
    final safeLastDate = now.add(const Duration(days: 1));
    final safeFirstDate = DateTime(2024);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: safeFirstDate,
      lastDate: safeLastDate,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),

      saveText: 'SELECIONAR',
      cancelText: 'CANCELAR',

      builder: (context, child) {
        final borderRadius = BorderRadius.circular(24);
        return Center(
          // Centraliza na tela
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 350.0, // Largura máxima (estilo cartão)
              maxHeight: 500.0, // Altura máxima
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.green.shade700, // Cor dos botões e seleção
                  onPrimary: Colors.white,
                  surface: Colors.white, // Fundo do Dialog
                  onSurface: Colors.black, // Texto
                ),
                datePickerTheme: DatePickerThemeData(
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  headerBackgroundColor: Colors.green.shade700,
                  // Cor do fundo do calendário
                  backgroundColor: Colors.white,
                ),
              ),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: Material(color: Colors.white, child: child!),
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      cubit.loadCustomEarnings(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Ganhos'), elevation: 0),
      body: BlocBuilder<DriverEarningsCubit, DriverEarningsState>(
        builder: (context, state) {
          // Estado Padrão de Filtro (para a UI não quebrar no loading inicial)
          EarningsFilter currentFilter = EarningsFilter.today;

          if (state is DriverEarningsLoading) {
            currentFilter = state.currentFilter;
          } else if (state is DriverEarningsLoaded) {
            currentFilter = state.currentFilter;
          }

          return Column(
            children: [
              // --- BARRA DE FILTROS ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Hoje',
                      isSelected: currentFilter == EarningsFilter.today,
                      onTap: () => context
                          .read<DriverEarningsCubit>()
                          .loadEarnings(EarningsFilter.today),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Esta Semana',
                      isSelected: currentFilter == EarningsFilter.weekly,
                      onTap: () => context
                          .read<DriverEarningsCubit>()
                          .loadEarnings(EarningsFilter.weekly),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Este Mês',
                      isSelected: currentFilter == EarningsFilter.monthly,
                      onTap: () => context
                          .read<DriverEarningsCubit>()
                          .loadEarnings(EarningsFilter.monthly),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: const Text('Outra Data'),
                      avatar: const Icon(Icons.calendar_today, size: 16),
                      backgroundColor: currentFilter == EarningsFilter.custom
                          ? Colors.green.shade100
                          : null,
                      onPressed: () => _selectCustomRange(context),
                    ),
                  ],
                ),
              ),

              // --- CONTEÚDO PRINCIPAL ---
              Expanded(child: _buildContent(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(DriverEarningsState state) {
    if (state is DriverEarningsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DriverEarningsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message, textAlign: TextAlign.center),
            TextButton(
              onPressed: () => context.read<DriverEarningsCubit>().loadEarnings(
                EarningsFilter.today,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (state is DriverEarningsLoaded) {
      final earnings = state.earnings;
      final formattedValue = NumberFormat.simpleCurrency(
        locale: 'pt_BR',
      ).format(earnings.totalEarnings);

      // Texto descritivo do período
      String periodText = '';
      if (state.currentFilter == EarningsFilter.custom &&
          state.customStartDate != null) {
        final start = DateFormat('dd/MM').format(state.customStartDate!);
        final end = DateFormat('dd/MM').format(state.customEndDate!);
        periodText = 'Período: $start até $end';
      }

      return RefreshIndicator(
        onRefresh: () async {
          // Recarrega o filtro atual
          final cubit = context.read<DriverEarningsCubit>();
          if (state.currentFilter == EarningsFilter.custom &&
              state.customStartDate != null) {
            await cubit.loadCustomEarnings(
              state.customStartDate!,
              state.customEndDate!,
            );
          } else {
            await cubit.loadEarnings(state.currentFilter);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (periodText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  periodText,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),

            // --- CARD DE GANHOS TOTAIS ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.green.shade600,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Ganhos Totais',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedValue,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- CARD DE ESTATÍSTICAS ---
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.directions_car,
                    label: 'Corridas',
                    value: '${earnings.totalRides}',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                // (Espaço para futura métrica, ex: Avaliação ou Km)
                const Expanded(
                  child: _StatCard(
                    icon: Icons.star,
                    label: 'Avaliação',
                    value: 'N/A', // Futuro
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              "Histórico Recente",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Aqui podemos colocar uma lista resumida das últimas corridas
            const Center(
              child: Text(
                "Detalhes em breve...",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// --- WIDGETS AUXILIARES ---

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.green.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.green.shade900 : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final MaterialColor color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

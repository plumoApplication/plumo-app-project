import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/core/services/service_locator.dart';
import 'package:plumo/app/features/driver_earnings/domain/entities/driver_earnings_entity.dart';
import 'package:plumo/app/features/driver_earnings/presentation/cubit/driver_earnings_cubit.dart';
import 'package:plumo/app/features/driver_earnings/presentation/cubit/driver_earnings_state.dart';

class DriverEarningsPage extends StatelessWidget {
  const DriverEarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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
  Future<void> _selectCustomRange(BuildContext context) async {
    final cubit = context.read<DriverEarningsCubit>();
    final now = DateTime.now();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now.add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Painel Financeiro',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocBuilder<DriverEarningsCubit, DriverEarningsState>(
        builder: (context, state) {
          final currentFilter = state is DriverEarningsLoaded
              ? state.currentFilter
              : (state is DriverEarningsLoading
                    ? state.currentFilter
                    : EarningsFilter.today);

          return Column(
            children: [
              // 1. NOVO SELETOR SEGMENTADO (Estilo do Print)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: _SegmentedFilterSelector(
                  selectedFilter: currentFilter,
                  onFilterChanged: (filter) {
                    if (filter == EarningsFilter.custom) {
                      _selectCustomRange(context);
                    } else {
                      context.read<DriverEarningsCubit>().loadEarnings(filter);
                    }
                  },
                ),
              ),

              // 2. CONTEÚDO
              Expanded(child: _buildBody(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(DriverEarningsState state) {
    if (state is DriverEarningsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (state is DriverEarningsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(state.message, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<DriverEarningsCubit>().loadEarnings(
                EarningsFilter.today,
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text(
                "Tentar novamente",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (state is DriverEarningsLoaded) {
      return RefreshIndicator(
        color: Colors.black,
        onRefresh: () async {
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
          padding: const EdgeInsets.all(20),
          children: [
            // EXIBIÇÃO DA DATA SELECIONADA (FEEDBACK VISUAL)
            if (state.currentFilter == EarningsFilter.custom &&
                state.customStartDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withAlpha(77)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${DateFormat('dd/MM').format(state.customStartDate!)} - ${DateFormat('dd/MM').format(state.customEndDate!)}",
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // CARD PRINCIPAL
            _BalanceCard(earnings: state.earnings),

            const SizedBox(height: 16),

            // GRID MÉTRICAS
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: "Feitas",
                    value: "${state.earnings.totalRides}",
                    icon: Icons.check_circle_outline,
                    color: Colors.green, // Verde para sucesso
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: "Canceladas",
                    value: "${state.earnings.totalCancelledRides}",
                    icon: Icons.cancel_outlined,
                    color: Colors.redAccent, // Vermelho para atenção
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: "Avaliação",
                    value: state.earnings.averageRating.toString(),
                    icon: Icons.star,
                    color: Colors.amber, // Amarelo/Ouro para rating
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // HISTÓRICO
            const Text(
              "Extrato Recente",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (state.earnings.recentTransactions.isEmpty)
              _buildEmptyHistory()
            else
              ...state.earnings.recentTransactions.map(
                (t) => _TransactionTile(transaction: t),
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text("Sem movimentações", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}

// --- NOVO COMPONENTE DE FILTRO (SEGMENTED CONTROL) ---
class _SegmentedFilterSelector extends StatelessWidget {
  final EarningsFilter selectedFilter;
  final Function(EarningsFilter) onFilterChanged;

  const _SegmentedFilterSelector({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100], // Fundo Cinza Claro do "Trilho"
        borderRadius: BorderRadius.circular(25), // Borda bem arredondada
      ),
      child: Row(
        children: [
          _buildSegmentOption("Hoje", EarningsFilter.today),
          _buildSegmentOption("Semana", EarningsFilter.weekly),
          _buildSegmentOption("Mês", EarningsFilter.monthly),
          _buildSegmentOption("Outro", EarningsFilter.custom, isIcon: true),
        ],
      ),
    );
  }

  Widget _buildSegmentOption(
    String label,
    EarningsFilter filter, {
    bool isIcon = false,
  }) {
    final isSelected = selectedFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: isIcon
              ? Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: isSelected ? Colors.black : Colors.grey[600],
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
        ),
      ),
    );
  }
}

// --- WIDGETS DE CONTEÚDO (Cards, Tiles) ---
class _BalanceCard extends StatelessWidget {
  final DriverEarningsEntity earnings;

  const _BalanceCard({required this.earnings});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Preto "Suave"
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ganhos Totais",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.remove_red_eye_outlined,
                color: Colors.white.withAlpha(77),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currency.format(earnings.totalEarnings),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          // Linha de Progresso Decorativa
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                height: 4,
                width: 100, // Dinâmico futuramente
                decoration: BoxDecoration(
                  color: const Color(0xFF4CE5B1), // Verde Neon suave
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final EarningTransactionEntity transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_taxi_outlined,
              color: Colors.black54,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat(
                    'dd MMM • HH:mm',
                    'pt_BR',
                  ).format(transaction.date),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            currency.format(transaction.amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF00C853), // Verde Sucesso
            ),
          ),
        ],
      ),
    );
  }
}

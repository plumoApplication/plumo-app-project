import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:plumo/app/core/database/app_database.dart'; // Import do Model RecentSearch
import 'package:plumo/app/features/trip_search/presentation/cubit/recent_searches/recent_searches_cubit.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/recent_searches/recent_searches_state.dart';

class RecentSearchesList extends StatelessWidget {
  final Function(RecentSearch) onSearchSelected;

  const RecentSearchesList({super.key, required this.onSearchSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecentSearchesCubit, RecentSearchesState>(
      builder: (context, state) {
        if (state is RecentSearchesLoaded && state.searches.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Buscas Recentes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Lista horizontal ou vertical. Vamos de Vertical enxuta.
              ListView.separated(
                shrinkWrap:
                    true, // Importante para usar dentro de Column/ScrollView
                physics:
                    const NeverScrollableScrollPhysics(), // Scroll controlado pela tela pai
                itemCount: state.searches.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final search = state.searches[index];
                  return _buildRecentItem(context, search);
                },
              ),
            ],
          );
        }
        // Se estiver carregando ou vazio, não mostra nada
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecentItem(BuildContext context, RecentSearch search) {
    final dateFormat = DateFormat('dd/MM', 'pt_BR');
    final dateString = dateFormat.format(search.tripDate);

    // Lógica visual: Se a data já passou, mostramos em vermelho ou cinza
    final isPast = search.tripDate.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    return InkWell(
      onTap: () => onSearchSelected(search),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history, color: Colors.grey, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${search.originText.split(',')[0]} ➝ ${search.destinationText.split(',')[0]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPast
                        ? "Data antiga: $dateString"
                        : "Viagem para $dateString",
                    style: TextStyle(
                      color: isPast ? Colors.red[300] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

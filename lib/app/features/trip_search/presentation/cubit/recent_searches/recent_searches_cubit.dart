import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/trip_search/data/repositories/recent_searches_repository.dart';
import 'package:plumo/app/features/trip_search/presentation/cubit/recent_searches/recent_searches_state.dart';

class RecentSearchesCubit extends Cubit<RecentSearchesState> {
  final RecentSearchesRepository _repository;

  RecentSearchesCubit({required RecentSearchesRepository repository})
    : _repository = repository,
      super(RecentSearchesInitial());

  /// Carrega a lista ao iniciar a tela
  Future<void> loadRecentSearches() async {
    emit(RecentSearchesLoading());
    try {
      final list = await _repository.getRecentSearches();
      emit(RecentSearchesLoaded(list));
    } catch (e) {
      // Se der erro, carregamos uma lista vazia para não quebrar a UI
      emit(const RecentSearchesLoaded([]));
    }
  }

  /// Salva uma busca e recarrega a lista
  Future<void> addSearch({
    required String originText,
    required String originId,
    required double originLat,
    required double originLng,
    required String destText,
    required String destId,
    required double destLat,
    required double destLng,
    required DateTime date,
    bool reloadList = true,
  }) async {
    await _repository.saveSearch(
      originText: originText,
      originId: originId,
      originLat: originLat,
      originLng: originLng,
      destText: destText,
      destId: destId,
      destLat: destLat,
      destLng: destLng,
      date: date,
    );
    // Só recarrega a lista se solicitado
    if (reloadList) {
      loadRecentSearches();
    }
  }
}

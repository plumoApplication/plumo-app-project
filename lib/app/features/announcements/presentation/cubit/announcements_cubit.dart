import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plumo/app/features/announcements/domain/repositories/announcements_repository.dart';
import 'package:plumo/app/features/announcements/presentation/cubit/announcements_state.dart';

class AnnouncementsCubit extends Cubit<AnnouncementsState> {
  final AnnouncementsRepository repository;

  // --- CACHE EM MEMÓRIA ---
  // Variável privada para saber se já buscamos os dados nesta sessão.
  bool _hasLoaded = false;

  AnnouncementsCubit({required this.repository})
    : super(AnnouncementsInitial());

  Future<void> loadAnnouncements(String role) async {
    // 1. Verifica o Cache
    if (_hasLoaded) {
      // Se já carregamos, não fazemos nada.
      // O estado atual (Loaded) será mantido.
      return;
    }

    emit(AnnouncementsLoading());

    // 2. Busca no Banco
    final result = await repository.getAnnouncements(role);

    result.fold(
      (failure) => emit(AnnouncementsError(message: failure.message)),
      (list) {
        // 3. Sucesso! Marca como carregado para não buscar mais.
        _hasLoaded = true;
        emit(AnnouncementsLoaded(announcements: list));
      },
    );
  }

  // (Opcional) Método para forçar recarga (ex: Pull-to-refresh)
  Future<void> refreshAnnouncements(String role) async {
    _hasLoaded = false; // Reseta o cache
    await loadAnnouncements(role);
  }

  void reset() {
    _hasLoaded = false; // Permite buscar de novo na próxima vez
    emit(AnnouncementsInitial()); // Limpa a tela
  }
}

import 'package:drift/drift.dart';
import 'package:plumo/app/core/database/app_database.dart';

class RecentSearchesRepository {
  final AppDatabase _db;

  RecentSearchesRepository(this._db);

  // Carrega as buscas (o banco já limita e ordena)
  Future<List<RecentSearch>> getRecentSearches() {
    return _db.getRecentSearches();
  }

  // Salva uma nova busca
  Future<void> saveSearch({
    required String originText,
    required String originId,
    required double originLat,
    required double originLng,
    required String destText,
    required String destId,
    required double destLat,
    required double destLng,
    required DateTime date,
  }) async {
    final entry = RecentSearchesCompanion(
      originText: Value(originText),
      originPlaceId: Value(originId),
      originLat: Value(originLat),
      originLng: Value(originLng),
      destinationText: Value(destText),
      destinationPlaceId: Value(destId),
      destinationLat: Value(destLat),
      destinationLng: Value(destLng),
      tripDate: Value(date),
      searchedAt: Value(
        DateTime.now(),
      ), // Data/Hora atual para ordenar corretamente
    );

    await _db.saveRecentSearch(entry);
  }

  Future<void> clearHistory() => _db.clearRecentSearches();
}

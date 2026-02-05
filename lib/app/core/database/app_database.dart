import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:plumo/app/core/database/tables/recent_searches_table.dart';

// Import gerado automaticamente (vai dar erro antes de rodar o build_runner)
part 'app_database.g.dart';

@DriftDatabase(tables: [RecentSearches])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- MÉTODOS DE BUSCA RECENTE ---

  /// Retorna as buscas ordenadas da mais recente para a mais antiga
  Future<List<RecentSearch>> getRecentSearches() {
    return (select(recentSearches)..orderBy([
          (t) =>
              OrderingTerm(expression: t.searchedAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  /// Salva uma nova busca e garante que só existam 5 no histórico
  Future<void> saveRecentSearch(RecentSearchesCompanion entry) async {
    return transaction(() async {
      // 1. Verifica se já existe uma busca idêntica (Mesma Origem, Destino e Data)
      // Se existir, deletamos a antiga para reinserir como "nova" (topo da lista)
      await (delete(recentSearches)..where(
            (t) =>
                t.originPlaceId.equals(entry.originPlaceId.value) &
                t.destinationPlaceId.equals(entry.destinationPlaceId.value) &
                t.tripDate.equals(entry.tripDate.value),
          ))
          .go();

      // 2. Insere a nova busca
      await into(recentSearches).insert(entry);

      // 3. Verifica quantas buscas temos armazenadas
      final allItems =
          await (select(recentSearches)..orderBy([
                (t) => OrderingTerm(
                  expression: t.searchedAt,
                  mode: OrderingMode.desc,
                ),
              ]))
              .get();

      // 4. Se tiver mais de 5, remove as excedentes (as mais antigas)
      if (allItems.length > 5) {
        final itemsToDelete = allItems.sublist(5); // Pega do 6º em diante
        for (var item in itemsToDelete) {
          await (delete(
            recentSearches,
          )..where((t) => t.id.equals(item.id))).go();
        }
      }
    });
  }

  // Método para limpar histórico (opcional, mas útil)
  Future<void> clearRecentSearches() => delete(recentSearches).go();
}

// Configuração da conexão com o arquivo SQLite
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

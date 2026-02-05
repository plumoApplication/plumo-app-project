import 'package:drift/drift.dart';

@DataClassName('RecentSearch')
class RecentSearches extends Table {
  // ID auto-incremental
  IntColumn get id => integer().autoIncrement()();

  // --- ORIGEM ---
  TextColumn get originText => text()(); // Ex: Natal, RN
  TextColumn get originPlaceId =>
      text()(); // ID do Google (importante para API)
  RealColumn get originLat => real()();
  RealColumn get originLng => real()();

  // --- DESTINO ---
  TextColumn get destinationText => text()();
  TextColumn get destinationPlaceId => text()();
  RealColumn get destinationLat => real()();
  RealColumn get destinationLng => real()();

  // --- DATA E CONTROLE ---
  DateTimeColumn get tripDate =>
      dateTime()(); // Data que o usuário escolheu viajar
  DateTimeColumn get searchedAt =>
      dateTime()(); // Data de QUANDO ele fez a busca (para ordenar)
}

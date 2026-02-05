// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RecentSearchesTable extends RecentSearches
    with TableInfo<$RecentSearchesTable, RecentSearch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentSearchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _originTextMeta =
      const VerificationMeta('originText');
  @override
  late final GeneratedColumn<String> originText = GeneratedColumn<String>(
      'origin_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originPlaceIdMeta =
      const VerificationMeta('originPlaceId');
  @override
  late final GeneratedColumn<String> originPlaceId = GeneratedColumn<String>(
      'origin_place_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originLatMeta =
      const VerificationMeta('originLat');
  @override
  late final GeneratedColumn<double> originLat = GeneratedColumn<double>(
      'origin_lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _originLngMeta =
      const VerificationMeta('originLng');
  @override
  late final GeneratedColumn<double> originLng = GeneratedColumn<double>(
      'origin_lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _destinationTextMeta =
      const VerificationMeta('destinationText');
  @override
  late final GeneratedColumn<String> destinationText = GeneratedColumn<String>(
      'destination_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _destinationPlaceIdMeta =
      const VerificationMeta('destinationPlaceId');
  @override
  late final GeneratedColumn<String> destinationPlaceId =
      GeneratedColumn<String>('destination_place_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _destinationLatMeta =
      const VerificationMeta('destinationLat');
  @override
  late final GeneratedColumn<double> destinationLat = GeneratedColumn<double>(
      'destination_lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _destinationLngMeta =
      const VerificationMeta('destinationLng');
  @override
  late final GeneratedColumn<double> destinationLng = GeneratedColumn<double>(
      'destination_lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _tripDateMeta =
      const VerificationMeta('tripDate');
  @override
  late final GeneratedColumn<DateTime> tripDate = GeneratedColumn<DateTime>(
      'trip_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _searchedAtMeta =
      const VerificationMeta('searchedAt');
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
      'searched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        originText,
        originPlaceId,
        originLat,
        originLng,
        destinationText,
        destinationPlaceId,
        destinationLat,
        destinationLng,
        tripDate,
        searchedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_searches';
  @override
  VerificationContext validateIntegrity(Insertable<RecentSearch> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('origin_text')) {
      context.handle(
          _originTextMeta,
          originText.isAcceptableOrUnknown(
              data['origin_text']!, _originTextMeta));
    } else if (isInserting) {
      context.missing(_originTextMeta);
    }
    if (data.containsKey('origin_place_id')) {
      context.handle(
          _originPlaceIdMeta,
          originPlaceId.isAcceptableOrUnknown(
              data['origin_place_id']!, _originPlaceIdMeta));
    } else if (isInserting) {
      context.missing(_originPlaceIdMeta);
    }
    if (data.containsKey('origin_lat')) {
      context.handle(_originLatMeta,
          originLat.isAcceptableOrUnknown(data['origin_lat']!, _originLatMeta));
    } else if (isInserting) {
      context.missing(_originLatMeta);
    }
    if (data.containsKey('origin_lng')) {
      context.handle(_originLngMeta,
          originLng.isAcceptableOrUnknown(data['origin_lng']!, _originLngMeta));
    } else if (isInserting) {
      context.missing(_originLngMeta);
    }
    if (data.containsKey('destination_text')) {
      context.handle(
          _destinationTextMeta,
          destinationText.isAcceptableOrUnknown(
              data['destination_text']!, _destinationTextMeta));
    } else if (isInserting) {
      context.missing(_destinationTextMeta);
    }
    if (data.containsKey('destination_place_id')) {
      context.handle(
          _destinationPlaceIdMeta,
          destinationPlaceId.isAcceptableOrUnknown(
              data['destination_place_id']!, _destinationPlaceIdMeta));
    } else if (isInserting) {
      context.missing(_destinationPlaceIdMeta);
    }
    if (data.containsKey('destination_lat')) {
      context.handle(
          _destinationLatMeta,
          destinationLat.isAcceptableOrUnknown(
              data['destination_lat']!, _destinationLatMeta));
    } else if (isInserting) {
      context.missing(_destinationLatMeta);
    }
    if (data.containsKey('destination_lng')) {
      context.handle(
          _destinationLngMeta,
          destinationLng.isAcceptableOrUnknown(
              data['destination_lng']!, _destinationLngMeta));
    } else if (isInserting) {
      context.missing(_destinationLngMeta);
    }
    if (data.containsKey('trip_date')) {
      context.handle(_tripDateMeta,
          tripDate.isAcceptableOrUnknown(data['trip_date']!, _tripDateMeta));
    } else if (isInserting) {
      context.missing(_tripDateMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
          _searchedAtMeta,
          searchedAt.isAcceptableOrUnknown(
              data['searched_at']!, _searchedAtMeta));
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecentSearch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentSearch(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      originText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin_text'])!,
      originPlaceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}origin_place_id'])!,
      originLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}origin_lat'])!,
      originLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}origin_lng'])!,
      destinationText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}destination_text'])!,
      destinationPlaceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}destination_place_id'])!,
      destinationLat: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}destination_lat'])!,
      destinationLng: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}destination_lng'])!,
      tripDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}trip_date'])!,
      searchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}searched_at'])!,
    );
  }

  @override
  $RecentSearchesTable createAlias(String alias) {
    return $RecentSearchesTable(attachedDatabase, alias);
  }
}

class RecentSearch extends DataClass implements Insertable<RecentSearch> {
  final int id;
  final String originText;
  final String originPlaceId;
  final double originLat;
  final double originLng;
  final String destinationText;
  final String destinationPlaceId;
  final double destinationLat;
  final double destinationLng;
  final DateTime tripDate;
  final DateTime searchedAt;
  const RecentSearch(
      {required this.id,
      required this.originText,
      required this.originPlaceId,
      required this.originLat,
      required this.originLng,
      required this.destinationText,
      required this.destinationPlaceId,
      required this.destinationLat,
      required this.destinationLng,
      required this.tripDate,
      required this.searchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['origin_text'] = Variable<String>(originText);
    map['origin_place_id'] = Variable<String>(originPlaceId);
    map['origin_lat'] = Variable<double>(originLat);
    map['origin_lng'] = Variable<double>(originLng);
    map['destination_text'] = Variable<String>(destinationText);
    map['destination_place_id'] = Variable<String>(destinationPlaceId);
    map['destination_lat'] = Variable<double>(destinationLat);
    map['destination_lng'] = Variable<double>(destinationLng);
    map['trip_date'] = Variable<DateTime>(tripDate);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  RecentSearchesCompanion toCompanion(bool nullToAbsent) {
    return RecentSearchesCompanion(
      id: Value(id),
      originText: Value(originText),
      originPlaceId: Value(originPlaceId),
      originLat: Value(originLat),
      originLng: Value(originLng),
      destinationText: Value(destinationText),
      destinationPlaceId: Value(destinationPlaceId),
      destinationLat: Value(destinationLat),
      destinationLng: Value(destinationLng),
      tripDate: Value(tripDate),
      searchedAt: Value(searchedAt),
    );
  }

  factory RecentSearch.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentSearch(
      id: serializer.fromJson<int>(json['id']),
      originText: serializer.fromJson<String>(json['originText']),
      originPlaceId: serializer.fromJson<String>(json['originPlaceId']),
      originLat: serializer.fromJson<double>(json['originLat']),
      originLng: serializer.fromJson<double>(json['originLng']),
      destinationText: serializer.fromJson<String>(json['destinationText']),
      destinationPlaceId:
          serializer.fromJson<String>(json['destinationPlaceId']),
      destinationLat: serializer.fromJson<double>(json['destinationLat']),
      destinationLng: serializer.fromJson<double>(json['destinationLng']),
      tripDate: serializer.fromJson<DateTime>(json['tripDate']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'originText': serializer.toJson<String>(originText),
      'originPlaceId': serializer.toJson<String>(originPlaceId),
      'originLat': serializer.toJson<double>(originLat),
      'originLng': serializer.toJson<double>(originLng),
      'destinationText': serializer.toJson<String>(destinationText),
      'destinationPlaceId': serializer.toJson<String>(destinationPlaceId),
      'destinationLat': serializer.toJson<double>(destinationLat),
      'destinationLng': serializer.toJson<double>(destinationLng),
      'tripDate': serializer.toJson<DateTime>(tripDate),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  RecentSearch copyWith(
          {int? id,
          String? originText,
          String? originPlaceId,
          double? originLat,
          double? originLng,
          String? destinationText,
          String? destinationPlaceId,
          double? destinationLat,
          double? destinationLng,
          DateTime? tripDate,
          DateTime? searchedAt}) =>
      RecentSearch(
        id: id ?? this.id,
        originText: originText ?? this.originText,
        originPlaceId: originPlaceId ?? this.originPlaceId,
        originLat: originLat ?? this.originLat,
        originLng: originLng ?? this.originLng,
        destinationText: destinationText ?? this.destinationText,
        destinationPlaceId: destinationPlaceId ?? this.destinationPlaceId,
        destinationLat: destinationLat ?? this.destinationLat,
        destinationLng: destinationLng ?? this.destinationLng,
        tripDate: tripDate ?? this.tripDate,
        searchedAt: searchedAt ?? this.searchedAt,
      );
  RecentSearch copyWithCompanion(RecentSearchesCompanion data) {
    return RecentSearch(
      id: data.id.present ? data.id.value : this.id,
      originText:
          data.originText.present ? data.originText.value : this.originText,
      originPlaceId: data.originPlaceId.present
          ? data.originPlaceId.value
          : this.originPlaceId,
      originLat: data.originLat.present ? data.originLat.value : this.originLat,
      originLng: data.originLng.present ? data.originLng.value : this.originLng,
      destinationText: data.destinationText.present
          ? data.destinationText.value
          : this.destinationText,
      destinationPlaceId: data.destinationPlaceId.present
          ? data.destinationPlaceId.value
          : this.destinationPlaceId,
      destinationLat: data.destinationLat.present
          ? data.destinationLat.value
          : this.destinationLat,
      destinationLng: data.destinationLng.present
          ? data.destinationLng.value
          : this.destinationLng,
      tripDate: data.tripDate.present ? data.tripDate.value : this.tripDate,
      searchedAt:
          data.searchedAt.present ? data.searchedAt.value : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearch(')
          ..write('id: $id, ')
          ..write('originText: $originText, ')
          ..write('originPlaceId: $originPlaceId, ')
          ..write('originLat: $originLat, ')
          ..write('originLng: $originLng, ')
          ..write('destinationText: $destinationText, ')
          ..write('destinationPlaceId: $destinationPlaceId, ')
          ..write('destinationLat: $destinationLat, ')
          ..write('destinationLng: $destinationLng, ')
          ..write('tripDate: $tripDate, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      originText,
      originPlaceId,
      originLat,
      originLng,
      destinationText,
      destinationPlaceId,
      destinationLat,
      destinationLng,
      tripDate,
      searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentSearch &&
          other.id == this.id &&
          other.originText == this.originText &&
          other.originPlaceId == this.originPlaceId &&
          other.originLat == this.originLat &&
          other.originLng == this.originLng &&
          other.destinationText == this.destinationText &&
          other.destinationPlaceId == this.destinationPlaceId &&
          other.destinationLat == this.destinationLat &&
          other.destinationLng == this.destinationLng &&
          other.tripDate == this.tripDate &&
          other.searchedAt == this.searchedAt);
}

class RecentSearchesCompanion extends UpdateCompanion<RecentSearch> {
  final Value<int> id;
  final Value<String> originText;
  final Value<String> originPlaceId;
  final Value<double> originLat;
  final Value<double> originLng;
  final Value<String> destinationText;
  final Value<String> destinationPlaceId;
  final Value<double> destinationLat;
  final Value<double> destinationLng;
  final Value<DateTime> tripDate;
  final Value<DateTime> searchedAt;
  const RecentSearchesCompanion({
    this.id = const Value.absent(),
    this.originText = const Value.absent(),
    this.originPlaceId = const Value.absent(),
    this.originLat = const Value.absent(),
    this.originLng = const Value.absent(),
    this.destinationText = const Value.absent(),
    this.destinationPlaceId = const Value.absent(),
    this.destinationLat = const Value.absent(),
    this.destinationLng = const Value.absent(),
    this.tripDate = const Value.absent(),
    this.searchedAt = const Value.absent(),
  });
  RecentSearchesCompanion.insert({
    this.id = const Value.absent(),
    required String originText,
    required String originPlaceId,
    required double originLat,
    required double originLng,
    required String destinationText,
    required String destinationPlaceId,
    required double destinationLat,
    required double destinationLng,
    required DateTime tripDate,
    required DateTime searchedAt,
  })  : originText = Value(originText),
        originPlaceId = Value(originPlaceId),
        originLat = Value(originLat),
        originLng = Value(originLng),
        destinationText = Value(destinationText),
        destinationPlaceId = Value(destinationPlaceId),
        destinationLat = Value(destinationLat),
        destinationLng = Value(destinationLng),
        tripDate = Value(tripDate),
        searchedAt = Value(searchedAt);
  static Insertable<RecentSearch> custom({
    Expression<int>? id,
    Expression<String>? originText,
    Expression<String>? originPlaceId,
    Expression<double>? originLat,
    Expression<double>? originLng,
    Expression<String>? destinationText,
    Expression<String>? destinationPlaceId,
    Expression<double>? destinationLat,
    Expression<double>? destinationLng,
    Expression<DateTime>? tripDate,
    Expression<DateTime>? searchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originText != null) 'origin_text': originText,
      if (originPlaceId != null) 'origin_place_id': originPlaceId,
      if (originLat != null) 'origin_lat': originLat,
      if (originLng != null) 'origin_lng': originLng,
      if (destinationText != null) 'destination_text': destinationText,
      if (destinationPlaceId != null)
        'destination_place_id': destinationPlaceId,
      if (destinationLat != null) 'destination_lat': destinationLat,
      if (destinationLng != null) 'destination_lng': destinationLng,
      if (tripDate != null) 'trip_date': tripDate,
      if (searchedAt != null) 'searched_at': searchedAt,
    });
  }

  RecentSearchesCompanion copyWith(
      {Value<int>? id,
      Value<String>? originText,
      Value<String>? originPlaceId,
      Value<double>? originLat,
      Value<double>? originLng,
      Value<String>? destinationText,
      Value<String>? destinationPlaceId,
      Value<double>? destinationLat,
      Value<double>? destinationLng,
      Value<DateTime>? tripDate,
      Value<DateTime>? searchedAt}) {
    return RecentSearchesCompanion(
      id: id ?? this.id,
      originText: originText ?? this.originText,
      originPlaceId: originPlaceId ?? this.originPlaceId,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destinationText: destinationText ?? this.destinationText,
      destinationPlaceId: destinationPlaceId ?? this.destinationPlaceId,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      tripDate: tripDate ?? this.tripDate,
      searchedAt: searchedAt ?? this.searchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (originText.present) {
      map['origin_text'] = Variable<String>(originText.value);
    }
    if (originPlaceId.present) {
      map['origin_place_id'] = Variable<String>(originPlaceId.value);
    }
    if (originLat.present) {
      map['origin_lat'] = Variable<double>(originLat.value);
    }
    if (originLng.present) {
      map['origin_lng'] = Variable<double>(originLng.value);
    }
    if (destinationText.present) {
      map['destination_text'] = Variable<String>(destinationText.value);
    }
    if (destinationPlaceId.present) {
      map['destination_place_id'] = Variable<String>(destinationPlaceId.value);
    }
    if (destinationLat.present) {
      map['destination_lat'] = Variable<double>(destinationLat.value);
    }
    if (destinationLng.present) {
      map['destination_lng'] = Variable<double>(destinationLng.value);
    }
    if (tripDate.present) {
      map['trip_date'] = Variable<DateTime>(tripDate.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentSearchesCompanion(')
          ..write('id: $id, ')
          ..write('originText: $originText, ')
          ..write('originPlaceId: $originPlaceId, ')
          ..write('originLat: $originLat, ')
          ..write('originLng: $originLng, ')
          ..write('destinationText: $destinationText, ')
          ..write('destinationPlaceId: $destinationPlaceId, ')
          ..write('destinationLat: $destinationLat, ')
          ..write('destinationLng: $destinationLng, ')
          ..write('tripDate: $tripDate, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecentSearchesTable recentSearches = $RecentSearchesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [recentSearches];
}

typedef $$RecentSearchesTableCreateCompanionBuilder = RecentSearchesCompanion
    Function({
  Value<int> id,
  required String originText,
  required String originPlaceId,
  required double originLat,
  required double originLng,
  required String destinationText,
  required String destinationPlaceId,
  required double destinationLat,
  required double destinationLng,
  required DateTime tripDate,
  required DateTime searchedAt,
});
typedef $$RecentSearchesTableUpdateCompanionBuilder = RecentSearchesCompanion
    Function({
  Value<int> id,
  Value<String> originText,
  Value<String> originPlaceId,
  Value<double> originLat,
  Value<double> originLng,
  Value<String> destinationText,
  Value<String> destinationPlaceId,
  Value<double> destinationLat,
  Value<double> destinationLng,
  Value<DateTime> tripDate,
  Value<DateTime> searchedAt,
});

class $$RecentSearchesTableFilterComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originText => $composableBuilder(
      column: $table.originText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originPlaceId => $composableBuilder(
      column: $table.originPlaceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originLat => $composableBuilder(
      column: $table.originLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get originLng => $composableBuilder(
      column: $table.originLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinationText => $composableBuilder(
      column: $table.destinationText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinationPlaceId => $composableBuilder(
      column: $table.destinationPlaceId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get destinationLat => $composableBuilder(
      column: $table.destinationLat,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get destinationLng => $composableBuilder(
      column: $table.destinationLng,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get tripDate => $composableBuilder(
      column: $table.tripDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
      column: $table.searchedAt, builder: (column) => ColumnFilters(column));
}

class $$RecentSearchesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originText => $composableBuilder(
      column: $table.originText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originPlaceId => $composableBuilder(
      column: $table.originPlaceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originLat => $composableBuilder(
      column: $table.originLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get originLng => $composableBuilder(
      column: $table.originLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinationText => $composableBuilder(
      column: $table.destinationText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinationPlaceId => $composableBuilder(
      column: $table.destinationPlaceId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get destinationLat => $composableBuilder(
      column: $table.destinationLat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get destinationLng => $composableBuilder(
      column: $table.destinationLng,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get tripDate => $composableBuilder(
      column: $table.tripDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
      column: $table.searchedAt, builder: (column) => ColumnOrderings(column));
}

class $$RecentSearchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentSearchesTable> {
  $$RecentSearchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originText => $composableBuilder(
      column: $table.originText, builder: (column) => column);

  GeneratedColumn<String> get originPlaceId => $composableBuilder(
      column: $table.originPlaceId, builder: (column) => column);

  GeneratedColumn<double> get originLat =>
      $composableBuilder(column: $table.originLat, builder: (column) => column);

  GeneratedColumn<double> get originLng =>
      $composableBuilder(column: $table.originLng, builder: (column) => column);

  GeneratedColumn<String> get destinationText => $composableBuilder(
      column: $table.destinationText, builder: (column) => column);

  GeneratedColumn<String> get destinationPlaceId => $composableBuilder(
      column: $table.destinationPlaceId, builder: (column) => column);

  GeneratedColumn<double> get destinationLat => $composableBuilder(
      column: $table.destinationLat, builder: (column) => column);

  GeneratedColumn<double> get destinationLng => $composableBuilder(
      column: $table.destinationLng, builder: (column) => column);

  GeneratedColumn<DateTime> get tripDate =>
      $composableBuilder(column: $table.tripDate, builder: (column) => column);

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
      column: $table.searchedAt, builder: (column) => column);
}

class $$RecentSearchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecentSearchesTable,
    RecentSearch,
    $$RecentSearchesTableFilterComposer,
    $$RecentSearchesTableOrderingComposer,
    $$RecentSearchesTableAnnotationComposer,
    $$RecentSearchesTableCreateCompanionBuilder,
    $$RecentSearchesTableUpdateCompanionBuilder,
    (
      RecentSearch,
      BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearch>
    ),
    RecentSearch,
    PrefetchHooks Function()> {
  $$RecentSearchesTableTableManager(
      _$AppDatabase db, $RecentSearchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentSearchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentSearchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentSearchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> originText = const Value.absent(),
            Value<String> originPlaceId = const Value.absent(),
            Value<double> originLat = const Value.absent(),
            Value<double> originLng = const Value.absent(),
            Value<String> destinationText = const Value.absent(),
            Value<String> destinationPlaceId = const Value.absent(),
            Value<double> destinationLat = const Value.absent(),
            Value<double> destinationLng = const Value.absent(),
            Value<DateTime> tripDate = const Value.absent(),
            Value<DateTime> searchedAt = const Value.absent(),
          }) =>
              RecentSearchesCompanion(
            id: id,
            originText: originText,
            originPlaceId: originPlaceId,
            originLat: originLat,
            originLng: originLng,
            destinationText: destinationText,
            destinationPlaceId: destinationPlaceId,
            destinationLat: destinationLat,
            destinationLng: destinationLng,
            tripDate: tripDate,
            searchedAt: searchedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String originText,
            required String originPlaceId,
            required double originLat,
            required double originLng,
            required String destinationText,
            required String destinationPlaceId,
            required double destinationLat,
            required double destinationLng,
            required DateTime tripDate,
            required DateTime searchedAt,
          }) =>
              RecentSearchesCompanion.insert(
            id: id,
            originText: originText,
            originPlaceId: originPlaceId,
            originLat: originLat,
            originLng: originLng,
            destinationText: destinationText,
            destinationPlaceId: destinationPlaceId,
            destinationLat: destinationLat,
            destinationLng: destinationLng,
            tripDate: tripDate,
            searchedAt: searchedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecentSearchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecentSearchesTable,
    RecentSearch,
    $$RecentSearchesTableFilterComposer,
    $$RecentSearchesTableOrderingComposer,
    $$RecentSearchesTableAnnotationComposer,
    $$RecentSearchesTableCreateCompanionBuilder,
    $$RecentSearchesTableUpdateCompanionBuilder,
    (
      RecentSearch,
      BaseReferences<_$AppDatabase, $RecentSearchesTable, RecentSearch>
    ),
    RecentSearch,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecentSearchesTableTableManager get recentSearches =>
      $$RecentSearchesTableTableManager(_db, _db.recentSearches);
}

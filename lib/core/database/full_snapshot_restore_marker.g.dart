// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'full_snapshot_restore_marker.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFullSnapshotRestoreMarkerCollection on Isar {
  IsarCollection<FullSnapshotRestoreMarker> get fullSnapshotRestoreMarkers =>
      this.collection();
}

const FullSnapshotRestoreMarkerSchema = CollectionSchema(
  name: r'FullSnapshotRestoreMarker',
  id: 2438697903591120877,
  properties: {},

  estimateSize: _fullSnapshotRestoreMarkerEstimateSize,
  serialize: _fullSnapshotRestoreMarkerSerialize,
  deserialize: _fullSnapshotRestoreMarkerDeserialize,
  deserializeProp: _fullSnapshotRestoreMarkerDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _fullSnapshotRestoreMarkerGetId,
  getLinks: _fullSnapshotRestoreMarkerGetLinks,
  attach: _fullSnapshotRestoreMarkerAttach,
  version: '3.3.2',
);

int _fullSnapshotRestoreMarkerEstimateSize(
  FullSnapshotRestoreMarker object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _fullSnapshotRestoreMarkerSerialize(
  FullSnapshotRestoreMarker object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {}
FullSnapshotRestoreMarker _fullSnapshotRestoreMarkerDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FullSnapshotRestoreMarker();
  object.id = id;
  return object;
}

P _fullSnapshotRestoreMarkerDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fullSnapshotRestoreMarkerGetId(FullSnapshotRestoreMarker object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fullSnapshotRestoreMarkerGetLinks(
  FullSnapshotRestoreMarker object,
) {
  return [];
}

void _fullSnapshotRestoreMarkerAttach(
  IsarCollection<dynamic> col,
  Id id,
  FullSnapshotRestoreMarker object,
) {
  object.id = id;
}

extension FullSnapshotRestoreMarkerQueryWhereSort
    on
        QueryBuilder<
          FullSnapshotRestoreMarker,
          FullSnapshotRestoreMarker,
          QWhere
        > {
  QueryBuilder<
    FullSnapshotRestoreMarker,
    FullSnapshotRestoreMarker,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FullSnapshotRestoreMarkerQueryWhere
    on
        QueryBuilder<
          FullSnapshotRestoreMarker,
          FullSnapshotRestoreMarker,
          QWhereClause
        > {
  QueryBuilder<
    FullSnapshotRestoreMarker,
    FullSnapshotRestoreMarker,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    FullSnapshotRestoreMarker,
    FullSnapshotRestoreMarker,
    QAfterWhereClause
  >
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<
    FullSnapshotRestoreMarker,
    FullSnapshotRestoreMarker,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    FullSnapshotRestoreMarker,
    FullSnapshotRestoreMarker,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    FullSnapshotRestoreMarker,
    FullSnapshotRestoreMarker,
    QAfterWhereClause
  >
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension FullSnapshotRestoreMarkerQueryFilter
    on
        QueryBuilder<
          FullSnapshotRestoreMarker,
          FullSnapshotRestoreMarker,
          QFilterCondition
        > {
  QueryBuilder<
    FullSnapshotRestoreMarker,
    FullSnapshotRestoreMarker,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    FullSnapshotRestoreMarker,
    FullSnapshotRestoreMarker,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    FullSnapshotRestoreMarker,
    FullSnapshotRestoreMarker,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    FullSnapshotRestoreMarker,
    FullSnapshotRestoreMarker,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension FullSnapshotRestoreMarkerQueryObject
    on
        QueryBuilder<
          FullSnapshotRestoreMarker,
          FullSnapshotRestoreMarker,
          QFilterCondition
        > {}

extension FullSnapshotRestoreMarkerQueryLinks
    on
        QueryBuilder<
          FullSnapshotRestoreMarker,
          FullSnapshotRestoreMarker,
          QFilterCondition
        > {}

extension FullSnapshotRestoreMarkerQuerySortBy
    on
        QueryBuilder<
          FullSnapshotRestoreMarker,
          FullSnapshotRestoreMarker,
          QSortBy
        > {}

extension FullSnapshotRestoreMarkerQuerySortThenBy
    on
        QueryBuilder<
          FullSnapshotRestoreMarker,
          FullSnapshotRestoreMarker,
          QSortThenBy
        > {
  QueryBuilder<
    FullSnapshotRestoreMarker,
    FullSnapshotRestoreMarker,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    FullSnapshotRestoreMarker,
    FullSnapshotRestoreMarker,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension FullSnapshotRestoreMarkerQueryWhereDistinct
    on
        QueryBuilder<
          FullSnapshotRestoreMarker,
          FullSnapshotRestoreMarker,
          QDistinct
        > {}

extension FullSnapshotRestoreMarkerQueryProperty
    on
        QueryBuilder<
          FullSnapshotRestoreMarker,
          FullSnapshotRestoreMarker,
          QQueryProperty
        > {
  QueryBuilder<FullSnapshotRestoreMarker, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }
}

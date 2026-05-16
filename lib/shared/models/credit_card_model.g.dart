// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCreditCardModelCollection on Isar {
  IsarCollection<CreditCardModel> get creditCardModels => this.collection();
}

const CreditCardModelSchema = CollectionSchema(
  name: r'CreditCardModel',
  id: 5536749382818049299,
  properties: {
    r'availableLimit': PropertySchema(
      id: 0,
      name: r'availableLimit',
      type: IsarType.long,
    ),
    r'billingDay': PropertySchema(
      id: 1,
      name: r'billingDay',
      type: IsarType.long,
    ),
    r'cardLimit': PropertySchema(
      id: 2,
      name: r'cardLimit',
      type: IsarType.long,
    ),
    r'cardName': PropertySchema(
      id: 3,
      name: r'cardName',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dueDay': PropertySchema(
      id: 5,
      name: r'dueDay',
      type: IsarType.long,
    ),
    r'interestRate': PropertySchema(
      id: 6,
      name: r'interestRate',
      type: IsarType.double,
    ),
    r'usedAmount': PropertySchema(
      id: 7,
      name: r'usedAmount',
      type: IsarType.long,
    )
  },
  estimateSize: _creditCardModelEstimateSize,
  serialize: _creditCardModelSerialize,
  deserialize: _creditCardModelDeserialize,
  deserializeProp: _creditCardModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _creditCardModelGetId,
  getLinks: _creditCardModelGetLinks,
  attach: _creditCardModelAttach,
  version: '3.1.0+1',
);

int _creditCardModelEstimateSize(
  CreditCardModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cardName.length * 3;
  return bytesCount;
}

void _creditCardModelSerialize(
  CreditCardModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.availableLimit);
  writer.writeLong(offsets[1], object.billingDay);
  writer.writeLong(offsets[2], object.cardLimit);
  writer.writeString(offsets[3], object.cardName);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeLong(offsets[5], object.dueDay);
  writer.writeDouble(offsets[6], object.interestRate);
  writer.writeLong(offsets[7], object.usedAmount);
}

CreditCardModel _creditCardModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CreditCardModel();
  object.availableLimit = reader.readLong(offsets[0]);
  object.billingDay = reader.readLong(offsets[1]);
  object.cardLimit = reader.readLong(offsets[2]);
  object.cardName = reader.readString(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.dueDay = reader.readLong(offsets[5]);
  object.id = id;
  object.interestRate = reader.readDouble(offsets[6]);
  object.usedAmount = reader.readLong(offsets[7]);
  return object;
}

P _creditCardModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _creditCardModelGetId(CreditCardModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _creditCardModelGetLinks(CreditCardModel object) {
  return [];
}

void _creditCardModelAttach(
    IsarCollection<dynamic> col, Id id, CreditCardModel object) {
  object.id = id;
}

extension CreditCardModelQueryWhereSort
    on QueryBuilder<CreditCardModel, CreditCardModel, QWhere> {
  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CreditCardModelQueryWhere
    on QueryBuilder<CreditCardModel, CreditCardModel, QWhereClause> {
  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause>
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

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CreditCardModelQueryFilter
    on QueryBuilder<CreditCardModel, CreditCardModel, QFilterCondition> {
  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      availableLimitEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'availableLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      availableLimitGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'availableLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      availableLimitLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'availableLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      availableLimitBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'availableLimit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      billingDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'billingDay',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      billingDayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'billingDay',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      billingDayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'billingDay',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      billingDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'billingDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardLimitEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardLimitGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardLimitLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardLimit',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardLimitBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardLimit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cardName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cardName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cardName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cardName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cardName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cardName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cardName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardName',
        value: '',
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      cardNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cardName',
        value: '',
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      dueDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueDay',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      dueDayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueDay',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      dueDayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueDay',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      dueDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      interestRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      interestRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      interestRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      interestRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interestRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      usedAmountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usedAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      usedAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usedAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      usedAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usedAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterFilterCondition>
      usedAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CreditCardModelQueryObject
    on QueryBuilder<CreditCardModel, CreditCardModel, QFilterCondition> {}

extension CreditCardModelQueryLinks
    on QueryBuilder<CreditCardModel, CreditCardModel, QFilterCondition> {}

extension CreditCardModelQuerySortBy
    on QueryBuilder<CreditCardModel, CreditCardModel, QSortBy> {
  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByAvailableLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableLimit', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByAvailableLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableLimit', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByBillingDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingDay', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByBillingDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingDay', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByCardLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardLimit', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByCardLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardLimit', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByCardName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardName', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByCardNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardName', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy> sortByDueDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDay', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByDueDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDay', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByInterestRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByUsedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usedAmount', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      sortByUsedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usedAmount', Sort.desc);
    });
  }
}

extension CreditCardModelQuerySortThenBy
    on QueryBuilder<CreditCardModel, CreditCardModel, QSortThenBy> {
  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByAvailableLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableLimit', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByAvailableLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableLimit', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByBillingDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingDay', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByBillingDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'billingDay', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByCardLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardLimit', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByCardLimitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardLimit', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByCardName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardName', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByCardNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardName', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy> thenByDueDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDay', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByDueDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDay', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByInterestRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.desc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByUsedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usedAmount', Sort.asc);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QAfterSortBy>
      thenByUsedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usedAmount', Sort.desc);
    });
  }
}

extension CreditCardModelQueryWhereDistinct
    on QueryBuilder<CreditCardModel, CreditCardModel, QDistinct> {
  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
      distinctByAvailableLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'availableLimit');
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
      distinctByBillingDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'billingDay');
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
      distinctByCardLimit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardLimit');
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct> distinctByCardName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct> distinctByDueDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDay');
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
      distinctByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interestRate');
    });
  }

  QueryBuilder<CreditCardModel, CreditCardModel, QDistinct>
      distinctByUsedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usedAmount');
    });
  }
}

extension CreditCardModelQueryProperty
    on QueryBuilder<CreditCardModel, CreditCardModel, QQueryProperty> {
  QueryBuilder<CreditCardModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CreditCardModel, int, QQueryOperations>
      availableLimitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'availableLimit');
    });
  }

  QueryBuilder<CreditCardModel, int, QQueryOperations> billingDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'billingDay');
    });
  }

  QueryBuilder<CreditCardModel, int, QQueryOperations> cardLimitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardLimit');
    });
  }

  QueryBuilder<CreditCardModel, String, QQueryOperations> cardNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardName');
    });
  }

  QueryBuilder<CreditCardModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CreditCardModel, int, QQueryOperations> dueDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDay');
    });
  }

  QueryBuilder<CreditCardModel, double, QQueryOperations>
      interestRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interestRate');
    });
  }

  QueryBuilder<CreditCardModel, int, QQueryOperations> usedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usedAmount');
    });
  }
}

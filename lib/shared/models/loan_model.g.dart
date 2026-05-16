// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLoanModelCollection on Isar {
  IsarCollection<LoanModel> get loanModels => this.collection();
}

const LoanModelSchema = CollectionSchema(
  name: r'LoanModel',
  id: -8609743036877683366,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'emiAmount': PropertySchema(
      id: 1,
      name: r'emiAmount',
      type: IsarType.long,
    ),
    r'endDate': PropertySchema(
      id: 2,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'interestRate': PropertySchema(
      id: 3,
      name: r'interestRate',
      type: IsarType.double,
    ),
    r'loanName': PropertySchema(
      id: 4,
      name: r'loanName',
      type: IsarType.string,
    ),
    r'principalAmount': PropertySchema(
      id: 5,
      name: r'principalAmount',
      type: IsarType.long,
    ),
    r'remainingAmount': PropertySchema(
      id: 6,
      name: r'remainingAmount',
      type: IsarType.long,
    ),
    r'startDate': PropertySchema(
      id: 7,
      name: r'startDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _loanModelEstimateSize,
  serialize: _loanModelSerialize,
  deserialize: _loanModelDeserialize,
  deserializeProp: _loanModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _loanModelGetId,
  getLinks: _loanModelGetLinks,
  attach: _loanModelAttach,
  version: '3.1.0+1',
);

int _loanModelEstimateSize(
  LoanModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.loanName.length * 3;
  return bytesCount;
}

void _loanModelSerialize(
  LoanModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.emiAmount);
  writer.writeDateTime(offsets[2], object.endDate);
  writer.writeDouble(offsets[3], object.interestRate);
  writer.writeString(offsets[4], object.loanName);
  writer.writeLong(offsets[5], object.principalAmount);
  writer.writeLong(offsets[6], object.remainingAmount);
  writer.writeDateTime(offsets[7], object.startDate);
}

LoanModel _loanModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LoanModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.emiAmount = reader.readLong(offsets[1]);
  object.endDate = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.interestRate = reader.readDouble(offsets[3]);
  object.loanName = reader.readString(offsets[4]);
  object.principalAmount = reader.readLong(offsets[5]);
  object.remainingAmount = reader.readLong(offsets[6]);
  object.startDate = reader.readDateTime(offsets[7]);
  return object;
}

P _loanModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _loanModelGetId(LoanModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _loanModelGetLinks(LoanModel object) {
  return [];
}

void _loanModelAttach(IsarCollection<dynamic> col, Id id, LoanModel object) {
  object.id = id;
}

extension LoanModelQueryWhereSort
    on QueryBuilder<LoanModel, LoanModel, QWhere> {
  QueryBuilder<LoanModel, LoanModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LoanModelQueryWhere
    on QueryBuilder<LoanModel, LoanModel, QWhereClause> {
  QueryBuilder<LoanModel, LoanModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<LoanModel, LoanModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterWhereClause> idBetween(
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

extension LoanModelQueryFilter
    on QueryBuilder<LoanModel, LoanModel, QFilterCondition> {
  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
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

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> emiAmountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emiAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
      emiAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emiAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> emiAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emiAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> emiAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emiAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> endDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> interestRateEqualTo(
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

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
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

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
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

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> interestRateBetween(
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

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> loanNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> loanNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> loanNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> loanNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loanName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> loanNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'loanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> loanNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'loanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> loanNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'loanName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> loanNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'loanName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> loanNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loanName',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
      loanNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'loanName',
        value: '',
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
      principalAmountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'principalAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
      principalAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'principalAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
      principalAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'principalAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
      principalAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'principalAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
      remainingAmountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remainingAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
      remainingAmountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remainingAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
      remainingAmountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remainingAmount',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
      remainingAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remainingAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> startDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterFilterCondition> startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LoanModelQueryObject
    on QueryBuilder<LoanModel, LoanModel, QFilterCondition> {}

extension LoanModelQueryLinks
    on QueryBuilder<LoanModel, LoanModel, QFilterCondition> {}

extension LoanModelQuerySortBy on QueryBuilder<LoanModel, LoanModel, QSortBy> {
  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByEmiAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByEmiAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByInterestRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByLoanName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanName', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByLoanNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanName', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByPrincipalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalAmount', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByPrincipalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalAmount', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByRemainingAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingAmount', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByRemainingAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingAmount', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }
}

extension LoanModelQuerySortThenBy
    on QueryBuilder<LoanModel, LoanModel, QSortThenBy> {
  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByEmiAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByEmiAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emiAmount', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByInterestRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interestRate', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByLoanName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanName', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByLoanNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loanName', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByPrincipalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalAmount', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByPrincipalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'principalAmount', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByRemainingAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingAmount', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByRemainingAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingAmount', Sort.desc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }
}

extension LoanModelQueryWhereDistinct
    on QueryBuilder<LoanModel, LoanModel, QDistinct> {
  QueryBuilder<LoanModel, LoanModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<LoanModel, LoanModel, QDistinct> distinctByEmiAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emiAmount');
    });
  }

  QueryBuilder<LoanModel, LoanModel, QDistinct> distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<LoanModel, LoanModel, QDistinct> distinctByInterestRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interestRate');
    });
  }

  QueryBuilder<LoanModel, LoanModel, QDistinct> distinctByLoanName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loanName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoanModel, LoanModel, QDistinct> distinctByPrincipalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'principalAmount');
    });
  }

  QueryBuilder<LoanModel, LoanModel, QDistinct> distinctByRemainingAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remainingAmount');
    });
  }

  QueryBuilder<LoanModel, LoanModel, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }
}

extension LoanModelQueryProperty
    on QueryBuilder<LoanModel, LoanModel, QQueryProperty> {
  QueryBuilder<LoanModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LoanModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<LoanModel, int, QQueryOperations> emiAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emiAmount');
    });
  }

  QueryBuilder<LoanModel, DateTime?, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<LoanModel, double, QQueryOperations> interestRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interestRate');
    });
  }

  QueryBuilder<LoanModel, String, QQueryOperations> loanNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loanName');
    });
  }

  QueryBuilder<LoanModel, int, QQueryOperations> principalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'principalAmount');
    });
  }

  QueryBuilder<LoanModel, int, QQueryOperations> remainingAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remainingAmount');
    });
  }

  QueryBuilder<LoanModel, DateTime, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }
}

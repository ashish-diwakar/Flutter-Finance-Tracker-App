import 'dart:convert';

import 'package:finance_tracker/shared/enums/fixed_return_type.dart';
import 'package:finance_tracker/shared/models/account_model.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:finance_tracker/shared/models/financial_goal_model.dart';
import 'package:finance_tracker/shared/models/investment_model.dart';
import 'package:finance_tracker/shared/models/recurring_transaction_model.dart';
import 'package:finance_tracker/shared/models/transaction_model.dart';

const _collectionNames = [
  'accounts',
  'categories',
  'transactions',
  'recurringTransactions',
  'financialGoals',
  'investments',
];

class ValidatedBackupRestorePlan {
  final String? appVersion;
  final String? currencyCode;
  final DateTime exportedAt;
  final List<AccountModel> accounts;
  final List<CategoryModel> categories;
  final List<TransactionModel> transactions;
  final List<RecurringTransactionModel> recurringTransactions;
  final List<FinancialGoalModel> financialGoals;
  final List<InvestmentModel> investments;
  final Map<String, int> recordCounts;
  final List<String> warnings;

  ValidatedBackupRestorePlan({
    required this.appVersion,
    required this.currencyCode,
    required this.exportedAt,
    required List<AccountModel> accounts,
    required List<CategoryModel> categories,
    required List<TransactionModel> transactions,
    required List<RecurringTransactionModel> recurringTransactions,
    required List<FinancialGoalModel> financialGoals,
    required List<InvestmentModel> investments,
    required Map<String, int> recordCounts,
    List<String> warnings = const [],
  }) : accounts = List.unmodifiable(accounts),
       categories = List.unmodifiable(categories),
       transactions = List.unmodifiable(transactions),
       recurringTransactions = List.unmodifiable(recurringTransactions),
       financialGoals = List.unmodifiable(financialGoals),
       investments = List.unmodifiable(investments),
       recordCounts = Map.unmodifiable(recordCounts),
       warnings = List.unmodifiable(warnings);

  int get totalRecordCount =>
      recordCounts.values.fold(0, (total, count) => total + count);
}

class BackupV2Preflight {
  static ValidatedBackupRestorePlan parse(String jsonText) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonText);
    } on FormatException {
      throw const FormatException('Backup is not valid JSON.');
    }

    final root = _object(decoded, r'$');
    if (!root.containsKey('format') &&
        !root.containsKey('schemaVersion') &&
        !root.containsKey('collections') &&
        const {'accounts', 'categories', 'transactions'}.any(root.containsKey)) {
      _fail(
        r'$',
        'This older incomplete backup format cannot be used for full restoration.',
      );
    }
    _keys(root, const {
      'format',
      'schemaVersion',
      'metadata',
      'manifest',
      'collections',
    }, r'$');

    if (root['format'] != 'finance-tracker-backup') {
      _fail(r'$.format', 'Unsupported backup format.');
    }
    if (root['schemaVersion'] != 2 || root['schemaVersion'] is! int) {
      _fail(r'$.schemaVersion', 'Unsupported backup schema version.');
    }

    final metadata = _object(root['metadata'], r'$.metadata');
    _allowedKeys(metadata, const {'exportedAt', 'appVersion', 'currencyCode'},
        r'$.metadata');
    if (!metadata.containsKey('exportedAt')) {
      _fail(r'$.metadata.exportedAt', 'Required metadata is missing.');
    }
    final exportedAt = _date(metadata['exportedAt'], r'$.metadata.exportedAt');
    final appVersion = _optionalString(
      metadata,
      'appVersion',
      r'$.metadata.appVersion',
    );
    final currencyCode = _optionalString(
      metadata,
      'currencyCode',
      r'$.metadata.currencyCode',
    );

    final manifest = _object(root['manifest'], r'$.manifest');
    _keys(manifest, _collectionNames.toSet(), r'$.manifest');
    final collections = _object(root['collections'], r'$.collections');
    _keys(collections, _collectionNames.toSet(), r'$.collections');

    final accounts = _parseAccounts(
      _array(collections['accounts'], r'$.collections.accounts'),
    );
    final categories = _parseCategories(
      _array(collections['categories'], r'$.collections.categories'),
    );
    final transactions = _parseTransactions(
      _array(collections['transactions'], r'$.collections.transactions'),
    );
    final recurringTransactions = _parseRecurringTransactions(
      _array(
        collections['recurringTransactions'],
        r'$.collections.recurringTransactions',
      ),
    );
    final financialGoals = _parseFinancialGoals(
      _array(collections['financialGoals'], r'$.collections.financialGoals'),
    );
    final investments = _parseInvestments(
      _array(collections['investments'], r'$.collections.investments'),
    );

    final recordCounts = {
      'accounts': accounts.length,
      'categories': categories.length,
      'transactions': transactions.length,
      'recurringTransactions': recurringTransactions.length,
      'financialGoals': financialGoals.length,
      'investments': investments.length,
    };
    for (final name in _collectionNames) {
      final path = '\$.manifest.$name';
      final collectionManifest = _object(
        manifest[name],
        path,
      );
      _keys(collectionManifest, const {'recordCount'}, path);
      if (_integer(
            collectionManifest['recordCount'],
            '$path.recordCount',
          ) !=
          recordCounts[name]) {
        _fail(path, 'Manifest count does not match the data.');
      }
    }

    _validateRelationships(
      accounts,
      categories,
      transactions,
      recurringTransactions,
      financialGoals,
    );

    return ValidatedBackupRestorePlan(
      appVersion: appVersion,
      currencyCode: currencyCode,
      exportedAt: exportedAt,
      accounts: accounts,
      categories: categories,
      transactions: transactions,
      recurringTransactions: recurringTransactions,
      financialGoals: financialGoals,
      investments: investments,
      recordCounts: recordCounts,
    );
  }

  static List<AccountModel> _parseAccounts(List<dynamic> input) {
    final output = <AccountModel>[];
    final ids = <String>{};
    for (var index = 0; index < input.length; index++) {
      final path = '\$.collections.accounts[$index]';
      final item = _object(input[index], path);
      _keys(item, const {
        'id',
        'name',
        'type',
        'currentBalance',
        'isArchived',
        'isDefault',
        'createdAt',
        'updatedAt',
        'isDeleted',
      }, path);
      final uuid = _uuid(item['id'], '$path.id');
      _unique(ids, uuid, '$path.id');
      final type = _string(item['type'], '$path.type');
      if (!const {'bank', 'cash', 'credit_card'}.contains(type)) {
        _fail('$path.type', 'Unsupported account type.');
      }
      output.add(
        AccountModel()
          ..uuid = uuid
          ..name = _nonEmptyString(item['name'], '$path.name')
          ..type = type
          ..currentBalance = _integer(
            item['currentBalance'],
            '$path.currentBalance',
          )
          ..isArchived = _boolean(item['isArchived'], '$path.isArchived')
          ..isDefault = _boolean(item['isDefault'], '$path.isDefault')
          ..createdAt = _date(item['createdAt'], '$path.createdAt')
          ..updatedAt = _nullableDate(item['updatedAt'], '$path.updatedAt')
          ..isDeleted = _boolean(item['isDeleted'], '$path.isDeleted'),
      );
    }
    return output;
  }

  static List<CategoryModel> _parseCategories(List<dynamic> input) {
    final output = <CategoryModel>[];
    final ids = <String>{};
    for (var index = 0; index < input.length; index++) {
      final path = '\$.collections.categories[$index]';
      final item = _object(input[index], path);
      _keys(item, const {
        'id',
        'name',
        'type',
        'icon',
        'colorValue',
        'isDefault',
        'createdAt',
        'updatedAt',
        'isDeleted',
        'monthlyBudget',
      }, path);
      final uuid = _uuid(item['id'], '$path.id');
      _unique(ids, uuid, '$path.id');
      final type = _string(item['type'], '$path.type');
      if (type != 'income' && type != 'expense') {
        _fail('$path.type', 'Unsupported category type.');
      }
      final monthlyBudget = _nullableInteger(
        item['monthlyBudget'],
        '$path.monthlyBudget',
      );
      if (monthlyBudget != null && monthlyBudget < 0) {
        _fail('$path.monthlyBudget', 'Monthly budget cannot be negative.');
      }
      output.add(
        CategoryModel()
          ..uuid = uuid
          ..name = _nonEmptyString(item['name'], '$path.name')
          ..type = type
          ..icon = _nullableString(item['icon'], '$path.icon')
          ..colorValue = _nullableInteger(item['colorValue'], '$path.colorValue')
          ..isDefault = _boolean(item['isDefault'], '$path.isDefault')
          ..createdAt = _date(item['createdAt'], '$path.createdAt')
          ..updatedAt = _nullableDate(item['updatedAt'], '$path.updatedAt')
          ..isDeleted = _boolean(item['isDeleted'], '$path.isDeleted')
          ..monthlyBudget = monthlyBudget,
      );
    }
    return output;
  }

  static List<TransactionModel> _parseTransactions(List<dynamic> input) {
    final output = <TransactionModel>[];
    final ids = <String>{};
    for (var index = 0; index < input.length; index++) {
      final path = '\$.collections.transactions[$index]';
      final item = _object(input[index], path);
      _keys(item, const {
        'id',
        'amount',
        'type',
        'categoryId',
        'accountId',
        'toAccountId',
        'counterpartyName',
        'relatedTransactionId',
        'dueDate',
        'notes',
        'transactionDate',
        'createdAt',
        'updatedAt',
        'isDeleted',
      }, path);
      final uuid = _uuid(item['id'], '$path.id');
      _unique(ids, uuid, '$path.id');
      final type = _string(item['type'], '$path.type');
      if (!const {
        'income',
        'expense',
        'transfer',
        'borrowed',
        'lent',
        'repaymentPaid',
        'repaymentReceived',
      }.contains(type)) {
        _fail('$path.type', 'Unsupported transaction type.');
      }
      final amount = _integer(item['amount'], '$path.amount');
      if (amount <= 0) _fail('$path.amount', 'Amount must be positive.');
      output.add(
        TransactionModel()
          ..uuid = uuid
          ..amount = amount
          ..type = type
          ..categoryId = _nullableString(item['categoryId'], '$path.categoryId')
          ..accountId = _uuid(item['accountId'], '$path.accountId')
          ..toAccountId = _nullableString(item['toAccountId'], '$path.toAccountId')
          ..counterpartyName = _nullableString(
            item['counterpartyName'],
            '$path.counterpartyName',
          )
          ..relatedTransactionId = _nullableString(
            item['relatedTransactionId'],
            '$path.relatedTransactionId',
          )
          ..dueDate = _nullableDate(item['dueDate'], '$path.dueDate')
          ..notes = _nullableString(item['notes'], '$path.notes')
          ..transactionDate = _date(
            item['transactionDate'],
            '$path.transactionDate',
          )
          ..createdAt = _date(item['createdAt'], '$path.createdAt')
          ..updatedAt = _nullableDate(item['updatedAt'], '$path.updatedAt')
          ..isDeleted = _boolean(item['isDeleted'], '$path.isDeleted'),
      );
    }
    return output;
  }

  static List<RecurringTransactionModel> _parseRecurringTransactions(
    List<dynamic> input,
  ) {
    final output = <RecurringTransactionModel>[];
    final ids = <String>{};
    for (var index = 0; index < input.length; index++) {
      final path = '\$.collections.recurringTransactions[$index]';
      final item = _object(input[index], path);
      _keys(item, const {
        'id',
        'amount',
        'type',
        'categoryId',
        'accountId',
        'notes',
        'startDate',
        'endDate',
        'frequency',
        'interval',
        'isActive',
        'nextRunDate',
        'updatedAt',
        'isDeleted',
      }, path);
      final uuid = _uuid(item['id'], '$path.id');
      _unique(ids, uuid, '$path.id');
      final type = _string(item['type'], '$path.type');
      if (type != 'income' && type != 'expense') {
        _fail('$path.type', 'Unsupported recurring transaction type.');
      }
      final amount = _integer(item['amount'], '$path.amount');
      if (amount <= 0) _fail('$path.amount', 'Amount must be positive.');
      final frequency = _string(item['frequency'], '$path.frequency');
      if (!const {'daily', 'weekly', 'monthly', 'yearly'}.contains(frequency)) {
        _fail('$path.frequency', 'Unsupported recurring frequency.');
      }
      final interval = _integer(item['interval'], '$path.interval');
      if (interval <= 0) _fail('$path.interval', 'Interval must be positive.');
      output.add(
        RecurringTransactionModel()
          ..uuid = uuid
          ..amount = amount
          ..type = type
          ..categoryId = _uuid(item['categoryId'], '$path.categoryId')
          ..accountId = _uuid(item['accountId'], '$path.accountId')
          ..notes = _nullableString(item['notes'], '$path.notes')
          ..startDate = _date(item['startDate'], '$path.startDate')
          ..endDate = _nullableDate(item['endDate'], '$path.endDate')
          ..frequency = frequency
          ..interval = interval
          ..isActive = _boolean(item['isActive'], '$path.isActive')
          ..nextRunDate = _date(item['nextRunDate'], '$path.nextRunDate')
          ..updatedAt = _date(item['updatedAt'], '$path.updatedAt')
          ..isDeleted = _boolean(item['isDeleted'], '$path.isDeleted'),
      );
    }
    return output;
  }

  static List<FinancialGoalModel> _parseFinancialGoals(List<dynamic> input) {
    final output = <FinancialGoalModel>[];
    final ids = <String>{};
    for (var index = 0; index < input.length; index++) {
      final path = '\$.collections.financialGoals[$index]';
      final item = _object(input[index], path);
      _keys(item, const {
        'id',
        'name',
        'description',
        'targetAmount',
        'currentAmount',
        'linkedAccountId',
        'targetDate',
        'createdAt',
        'updatedAt',
        'isCompleted',
        'isDeleted',
      }, path);
      final uuid = _uuid(item['id'], '$path.id');
      _unique(ids, uuid, '$path.id');
      final targetAmount = _integer(item['targetAmount'], '$path.targetAmount');
      final currentAmount = _integer(item['currentAmount'], '$path.currentAmount');
      if (targetAmount <= 0) {
        _fail('$path.targetAmount', 'Target amount must be positive.');
      }
      if (currentAmount < 0) {
        _fail('$path.currentAmount', 'Current amount cannot be negative.');
      }
      output.add(
        FinancialGoalModel()
          ..uuid = uuid
          ..name = _nonEmptyString(item['name'], '$path.name')
          ..description = _nullableString(item['description'], '$path.description')
          ..targetAmount = targetAmount
          ..currentAmount = currentAmount
          ..linkedAccountId = _nullableString(
            item['linkedAccountId'],
            '$path.linkedAccountId',
          )
          ..targetDate = _nullableDate(item['targetDate'], '$path.targetDate')
          ..createdAt = _date(item['createdAt'], '$path.createdAt')
          ..updatedAt = _date(item['updatedAt'], '$path.updatedAt')
          ..isCompleted = _boolean(item['isCompleted'], '$path.isCompleted')
          ..isDeleted = _boolean(item['isDeleted'], '$path.isDeleted'),
      );
    }
    return output;
  }

  static List<InvestmentModel> _parseInvestments(List<dynamic> input) {
    final output = <InvestmentModel>[];
    final ids = <String>{};
    const investmentTypes = {
      'Stock',
      'Mutual Fund',
      'ETF',
      'Gold',
      'Crypto',
      'FD',
      'RD',
      'PPF',
      'EPF',
      'NPS',
      'Bond',
    };
    for (var index = 0; index < input.length; index++) {
      final path = '\$.collections.investments[$index]';
      final item = _object(input[index], path);
      _keys(item, const {
        'id',
        'name',
        'type',
        'symbol',
        'notes',
        'quantity',
        'purchasePrice',
        'currentPrice',
        'purchaseDate',
        'createdAt',
        'updatedAt',
        'interestRate',
        'maturityDate',
        'maturityValue',
        'investmentClass',
        'isDeleted',
      }, path);
      final uuid = _uuid(item['id'], '$path.id');
      _unique(ids, uuid, '$path.id');
      final type = _string(item['type'], '$path.type');
      if (!investmentTypes.contains(type)) {
        _fail('$path.type', 'Unsupported investment type.');
      }
      final investmentClass = _string(
        item['investmentClass'],
        '$path.investmentClass',
      );
      final expectedClass = fixedReturnTypes.contains(type) ? 'fixed' : 'market';
      if (investmentClass != expectedClass) {
        _fail('$path.investmentClass', 'Investment classification is invalid.');
      }
      final quantity = _integer(item['quantity'], '$path.quantity');
      final purchasePrice = _integer(item['purchasePrice'], '$path.purchasePrice');
      final currentPrice = _integer(item['currentPrice'], '$path.currentPrice');
      if (quantity <= 0) _fail('$path.quantity', 'Quantity must be positive.');
      if (purchasePrice < 0 || currentPrice < 0) {
        _fail(path, 'Investment prices cannot be negative.');
      }
      final interestRate = _nullableNumber(
        item['interestRate'],
        '$path.interestRate',
      );
      if (interestRate != null && interestRate < 0) {
        _fail('$path.interestRate', 'Interest rate cannot be negative.');
      }
      final maturityValue = _nullableInteger(
        item['maturityValue'],
        '$path.maturityValue',
      );
      if (maturityValue != null && maturityValue < 0) {
        _fail('$path.maturityValue', 'Maturity value cannot be negative.');
      }
      output.add(
        InvestmentModel()
          ..uuid = uuid
          ..name = _nonEmptyString(item['name'], '$path.name')
          ..type = type
          ..symbol = _nullableString(item['symbol'], '$path.symbol')
          ..notes = _nullableString(item['notes'], '$path.notes')
          ..quantity = quantity
          ..purchasePrice = purchasePrice
          ..currentPrice = currentPrice
          ..purchaseDate = _date(item['purchaseDate'], '$path.purchaseDate')
          ..createdAt = _date(item['createdAt'], '$path.createdAt')
          ..updatedAt = _date(item['updatedAt'], '$path.updatedAt')
          ..interestRate = interestRate
          ..maturityDate = _nullableDate(item['maturityDate'], '$path.maturityDate')
          ..maturityValue = maturityValue
          ..investmentClass = investmentClass
          ..isDeleted = _boolean(item['isDeleted'], '$path.isDeleted'),
      );
    }
    return output;
  }

  static void _validateRelationships(
    List<AccountModel> accounts,
    List<CategoryModel> categories,
    List<TransactionModel> transactions,
    List<RecurringTransactionModel> recurringTransactions,
    List<FinancialGoalModel> financialGoals,
  ) {
    final accountsById = {for (final item in accounts) item.uuid: item};
    final categoriesById = {for (final item in categories) item.uuid: item};
    final transactionsById = {for (final item in transactions) item.uuid: item};

    for (final transaction in transactions) {
      final path = 'transactions[${transaction.uuid}]';
      if (!accountsById.containsKey(transaction.accountId)) {
        _fail('$path.accountId', 'Referenced account is missing.');
      }
      final category = transaction.categoryId == null
          ? null
          : categoriesById[transaction.categoryId];
      if (transaction.type == 'income' || transaction.type == 'expense') {
        if (category == null) {
          _fail('$path.categoryId', 'A matching category is required.');
        }
        if (category.type != transaction.type) {
          _fail('$path.categoryId', 'Category type does not match transaction.');
        }
        if (transaction.toAccountId != null ||
            transaction.relatedTransactionId != null) {
          _fail(path, 'Transaction has an incompatible relationship field.');
        }
      } else if (transaction.type == 'transfer') {
        final destination = transaction.toAccountId == null
            ? null
            : accountsById[transaction.toAccountId];
        if (destination == null) {
          _fail('$path.toAccountId', 'Transfer destination is missing.');
        }
        if (destination.uuid == transaction.accountId) {
          _fail('$path.toAccountId', 'Transfer accounts must be different.');
        }
        if (transaction.categoryId != null ||
            transaction.relatedTransactionId != null) {
          _fail(path, 'Transfer has an incompatible relationship field.');
        }
      } else if (transaction.type == 'borrowed' ||
          transaction.type == 'lent') {
        if (transaction.categoryId != null ||
            transaction.toAccountId != null ||
            transaction.relatedTransactionId != null) {
          _fail(path, 'Borrow/lend transaction has incompatible references.');
        }
      } else {
        if (transaction.categoryId != null || transaction.toAccountId != null) {
          _fail(path, 'Repayment has incompatible references.');
        }
        final parentId = transaction.relatedTransactionId;
        final parent = parentId == null ? null : transactionsById[parentId];
        if (parent == null) {
          _fail(
            '$path.relatedTransactionId',
            'Repayment parent is missing.',
          );
        }
        final expectedParentType = transaction.type == 'repaymentPaid'
            ? 'borrowed'
            : 'lent';
        if (parent.type != expectedParentType) {
          _fail(
            '$path.relatedTransactionId',
            'Repayment parent has an incompatible transaction type.',
          );
        }
      }
    }

    for (final recurring in recurringTransactions) {
      final path = 'recurringTransactions[${recurring.uuid}]';
      if (!accountsById.containsKey(recurring.accountId)) {
        _fail('$path.accountId', 'Referenced account is missing.');
      }
      final category = categoriesById[recurring.categoryId];
      if (category == null) {
        _fail('$path.categoryId', 'Referenced category is missing.');
      }
      if (category.type != recurring.type) {
        _fail('$path.categoryId', 'Category type does not match schedule.');
      }
    }

    for (final goal in financialGoals) {
      if (goal.linkedAccountId != null &&
          !accountsById.containsKey(goal.linkedAccountId)) {
        _fail(
          'financialGoals[${goal.uuid}].linkedAccountId',
          'Referenced account is missing.',
        );
      }
    }
  }
}

Map<String, dynamic> _object(dynamic value, String path) {
  if (value is! Map<String, dynamic>) {
    _fail(path, 'Expected an object.');
  }
  return value;
}

List<dynamic> _array(dynamic value, String path) {
  if (value is! List) _fail(path, 'Expected an array.');
  return value;
}

void _keys(Map<String, dynamic> value, Set<String> required, String path) {
  final missing = required.difference(value.keys.toSet());
  if (missing.isNotEmpty) {
    _fail(path, 'Required fields are missing: ${missing.join(', ')}.');
  }
  _allowedKeys(value, required, path);
}

void _allowedKeys(Map<String, dynamic> value, Set<String> allowed, String path) {
  final unknown = value.keys.toSet().difference(allowed);
  if (unknown.isNotEmpty) {
    _fail(path, 'Unsupported fields are present: ${unknown.join(', ')}.');
  }
}

String _string(dynamic value, String path) {
  if (value is! String) _fail(path, 'Expected text.');
  return value;
}

String _nonEmptyString(dynamic value, String path) {
  final result = _string(value, path);
  if (result.trim().isEmpty) _fail(path, 'Value cannot be empty.');
  return result;
}

String? _nullableString(dynamic value, String path) {
  if (value == null) return null;
  return _string(value, path);
}

String? _optionalString(
  Map<String, dynamic> value,
  String key,
  String path,
) => value.containsKey(key) ? _nullableString(value[key], path) : null;

bool _boolean(dynamic value, String path) {
  if (value is! bool) _fail(path, 'Expected a boolean.');
  return value;
}

int _integer(dynamic value, String path) {
  if (value is! int || value < -9223372036854775808 || value > 9223372036854775807) {
    _fail(path, 'Expected a signed 64-bit integer.');
  }
  return value;
}

int? _nullableInteger(dynamic value, String path) =>
    value == null ? null : _integer(value, path);

double? _nullableNumber(dynamic value, String path) {
  if (value == null) return null;
  if (value is! num || !value.toDouble().isFinite) {
    _fail(path, 'Expected a finite number.');
  }
  return value.toDouble();
}

DateTime _date(dynamic value, String path) {
  if (value is! String ||
      !RegExp(
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$',
      ).hasMatch(value)) {
    _fail(path, 'Expected an ISO-8601 timestamp.');
  }
  final result = DateTime.tryParse(value);
  if (result == null) _fail(path, 'Invalid date.');
  return result.toUtc();
}

DateTime? _nullableDate(dynamic value, String path) =>
    value == null ? null : _date(value, path);

String _uuid(dynamic value, String path) {
  final result = _string(value, path);
  if (!RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  ).hasMatch(result)) {
    _fail(path, 'Expected a canonical UUID.');
  }
  return result;
}

void _unique(Set<String> ids, String id, String path) {
  if (!ids.add(id)) _fail(path, 'Duplicate UUID in collection.');
}

Never _fail(String path, String message) {
  throw FormatException('$path: $message');
}

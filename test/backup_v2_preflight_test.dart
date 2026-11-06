import 'dart:convert';

import 'package:finance_tracker/features/backup/domain/services/backup_v2_preflight.dart';
import 'package:flutter_test/flutter_test.dart';

String _uuid(int value) =>
    '00000000-0000-4000-8000-${value.toString().padLeft(12, '0')}';

Map<String, dynamic> _account(int id, {bool isDeleted = false}) => {
  'id': _uuid(id),
  'name': 'Account $id',
  'type': 'cash',
  'currentBalance': 9007199254740991,
  'isArchived': false,
  'isDefault': false,
  'createdAt': '2026-01-01T00:00:00.000Z',
  'updatedAt': null,
  'isDeleted': isDeleted,
};

Map<String, dynamic> _category(int id, String type, {bool isDeleted = false}) =>
    {
      'id': _uuid(id),
      'name': 'Category $id',
      'type': type,
      'icon': null,
      'colorValue': null,
      'isDefault': false,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': null,
      'isDeleted': isDeleted,
      'monthlyBudget': null,
    };

Map<String, dynamic> _transaction(
  int id,
  String type, {
  required String accountId,
  String? categoryId,
  String? toAccountId,
  String? relatedTransactionId,
  bool isDeleted = false,
}) => {
  'id': _uuid(id),
  'amount': 9007199254740991,
  'type': type,
  'categoryId': categoryId,
  'accountId': accountId,
  'toAccountId': toAccountId,
  'counterpartyName': null,
  'relatedTransactionId': relatedTransactionId,
  'dueDate': null,
  'notes': null,
  'transactionDate': '2026-01-02T00:00:00.000Z',
  'createdAt': '2026-01-02T00:00:00.000Z',
  'updatedAt': null,
  'isDeleted': isDeleted,
};

Map<String, dynamic> _recurring(int id, String categoryId, String accountId) =>
    {
      'id': _uuid(id),
      'amount': 150,
      'type': 'expense',
      'categoryId': categoryId,
      'accountId': accountId,
      'notes': null,
      'startDate': '2026-01-01T00:00:00.000Z',
      'endDate': null,
      'frequency': 'monthly',
      'interval': 1,
      'isActive': true,
      'nextRunDate': '2026-02-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'isDeleted': false,
    };

Map<String, dynamic> _goal(int id, String accountId) => {
  'id': _uuid(id),
  'name': 'Goal',
  'description': null,
  'targetAmount': 10000,
  'currentAmount': 1250,
  'linkedAccountId': accountId,
  'targetDate': null,
  'createdAt': '2026-01-01T00:00:00.000Z',
  'updatedAt': '2026-01-01T00:00:00.000Z',
  'isCompleted': false,
  'isDeleted': false,
};

Map<String, dynamic> _investment(int id) => {
  'id': _uuid(id),
  'name': 'Fixed deposit',
  'type': 'FD',
  'symbol': null,
  'notes': null,
  'quantity': 1,
  'purchasePrice': 9007199254740991,
  'currentPrice': 9007199254740991,
  'purchaseDate': '2026-01-01T00:00:00.000Z',
  'createdAt': '2026-01-01T00:00:00.000Z',
  'updatedAt': '2026-01-01T00:00:00.000Z',
  'interestRate': 7.123456789012345,
  'maturityDate': null,
  'maturityValue': null,
  'investmentClass': 'fixed',
  'isDeleted': false,
};

Map<String, dynamic> _document({bool populated = true}) {
  final collections = <String, dynamic>{
    'accounts': <dynamic>[],
    'categories': <dynamic>[],
    'transactions': <dynamic>[],
    'recurringTransactions': <dynamic>[],
    'financialGoals': <dynamic>[],
    'investments': <dynamic>[],
  };
  if (populated) {
    collections['accounts'] = [_account(1, isDeleted: true), _account(2)];
    collections['categories'] = [
      _category(10, 'income'),
      _category(11, 'expense', isDeleted: true),
    ];
    collections['transactions'] = [
      _transaction(20, 'income', accountId: _uuid(1), categoryId: _uuid(10)),
      _transaction(21, 'transfer', accountId: _uuid(1), toAccountId: _uuid(2)),
      _transaction(22, 'borrowed', accountId: _uuid(1), isDeleted: true),
      _transaction(
        23,
        'repaymentPaid',
        accountId: _uuid(2),
        relatedTransactionId: _uuid(22),
      ),
      _transaction(24, 'lent', accountId: _uuid(2)),
      _transaction(
        25,
        'repaymentReceived',
        accountId: _uuid(1),
        relatedTransactionId: _uuid(24),
      ),
    ];
    collections['recurringTransactions'] = [
      _recurring(30, _uuid(11), _uuid(1)),
    ];
    collections['financialGoals'] = [_goal(40, _uuid(1))];
    collections['investments'] = [_investment(50)];
  }

  final counts = {
    for (final entry in collections.entries)
      entry.key: {'recordCount': (entry.value as List).length},
  };
  return {
    'format': 'finance-tracker-backup',
    'schemaVersion': 2,
    'metadata': {
      'exportedAt': '2026-01-03T00:00:00.000Z',
      'appVersion': null,
      'currencyCode': 'USD',
    },
    'manifest': counts,
    'collections': collections,
  };
}

Map<String, dynamic> _copyDocument(Map<String, dynamic> document) =>
    jsonDecode(jsonEncode(document)) as Map<String, dynamic>;

void main() {
  test('valid complete V2 snapshot preserves all six typed collections', () {
    final plan = BackupV2Preflight.parse(jsonEncode(_document()));

    expect(plan.accounts, hasLength(2));
    expect(plan.categories, hasLength(2));
    expect(plan.transactions, hasLength(6));
    expect(plan.recurringTransactions, hasLength(1));
    expect(plan.financialGoals, hasLength(1));
    expect(plan.investments, hasLength(1));
    expect(plan.totalRecordCount, 13);
    expect(plan.recordCounts['investments'], 1);
    expect(plan.accounts.first.uuid, _uuid(1));
    expect(plan.accounts.first.currentBalance, 9007199254740991);
    expect(plan.transactions[1].toAccountId, _uuid(2));
    expect(plan.transactions[3].relatedTransactionId, _uuid(22));
    expect(plan.financialGoals.single.linkedAccountId, _uuid(1));
    expect(
      plan.investments.single.interestRate,
      closeTo(7.123456789012345, 0.000000000000001),
    );
    expect(plan.warnings, isEmpty);
  });

  test('explicit empty collections and optional metadata are accepted', () {
    final document = _document(populated: false);
    final metadata = document['metadata'] as Map<String, dynamic>
      ..remove('currencyCode');

    final plan = BackupV2Preflight.parse(jsonEncode(document));

    expect(plan.totalRecordCount, 0);
    expect(plan.appVersion, isNull);
    expect(plan.currencyCode, isNull);
    expect(metadata['appVersion'], isNull);
  });

  test(
    'missing collections, malformed data, and unsupported versions reject',
    () {
      for (final name in [
        'accounts',
        'categories',
        'transactions',
        'recurringTransactions',
        'financialGoals',
        'investments',
      ]) {
        final document = _copyDocument(_document(populated: false));
        (document['collections'] as Map<String, dynamic>).remove(name);
        expect(
          () => BackupV2Preflight.parse(jsonEncode(document)),
          throwsFormatException,
          reason: name,
        );
      }

      for (final document in [
        {'format': 'wrong'},
        {..._document(), 'schemaVersion': 3},
        {..._document(), 'schemaVersion': 2.0},
      ]) {
        expect(
          () => BackupV2Preflight.parse(jsonEncode(document)),
          throwsFormatException,
        );
      }
      expect(() => BackupV2Preflight.parse('{not json'), throwsFormatException);
      expect(
        () => BackupV2Preflight.parse(
          jsonEncode({'accounts': [], 'categories': [], 'transactions': []}),
        ),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('older incomplete backup format'),
          ),
        ),
        reason: 'Legacy V1 is not a complete V2 snapshot.',
      );
    },
  );

  test('missing, duplicate, malformed IDs and financial fields reject', () {
    final changes = <void Function(Map<String, dynamic>)>[
      (document) {
        ((document['collections'] as Map)['accounts'] as List).first.remove(
          'id',
        );
      },
      (document) {
        final accounts = (document['collections'] as Map)['accounts'] as List;
        accounts[1]['id'] = accounts[0]['id'];
      },
      (document) {
        (((document['collections'] as Map)['transactions'] as List).first
                as Map)['amount'] =
            1.5;
      },
      (document) {
        (((document['collections'] as Map)['transactions'] as List).first
                as Map)['transactionDate'] =
            'not a date';
      },
      (document) {
        (((document['collections'] as Map)['transactions'] as List).first
                as Map)['type'] =
            'unknown';
      },
    ];
    for (final change in changes) {
      final document = _copyDocument(_document());
      change(document);
      expect(
        () => BackupV2Preflight.parse(jsonEncode(document)),
        throwsFormatException,
      );
    }
  });

  test('manifest counts must match each full snapshot collection', () {
    final document = _copyDocument(_document());
    (document['manifest'] as Map<String, dynamic>)['accounts'] = {
      'recordCount': 99,
    };

    expect(
      () => BackupV2Preflight.parse(jsonEncode(document)),
      throwsFormatException,
    );
  });

  test(
    'invalid transfer, repayment, recurring, and goal references reject',
    () {
      final cases = <void Function(Map<String, dynamic>)>[
        (document) {
          final transaction =
              ((document['collections'] as Map)['transactions'] as List)[1]
                  as Map;
          transaction['toAccountId'] = transaction['accountId'];
        },
        (document) {
          final transaction =
              ((document['collections'] as Map)['transactions'] as List)[3]
                  as Map;
          transaction['relatedTransactionId'] = _uuid(24);
        },
        (document) {
          final recurring =
              ((document['collections'] as Map)['recurringTransactions']
                          as List)
                      .single
                  as Map;
          recurring['accountId'] = _uuid(999);
        },
        (document) {
          final goal =
              ((document['collections'] as Map)['financialGoals'] as List)
                      .single
                  as Map;
          goal['linkedAccountId'] = _uuid(999);
        },
      ];

      for (final change in cases) {
        final document = _copyDocument(_document());
        change(document);
        expect(
          () => BackupV2Preflight.parse(jsonEncode(document)),
          throwsFormatException,
        );
      }
    },
  );
}

import '../../shared/models/account_model.dart';
import '../../shared/models/category_model.dart';

class DefaultData {

  // ==========================================
  // DEFAULT CATEGORY UUIDS
  // ==========================================

  static const defaultUuid =
      '11111111-1111-1111-1111-111111111111';


  // ==========================================
  // DEFAULT CATEGORIES
  // ==========================================

  static List<CategoryModel> categories = [

    CategoryModel()
      ..uuid = defaultUuid
      ..name = 'Food'
      ..type = 'expense'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now().toUtc(),

    CategoryModel()
      ..uuid = defaultUuid
      ..name = 'Shopping'
      ..type = 'expense'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now().toUtc(),

    CategoryModel()
      ..uuid = defaultUuid
      ..name = 'Fuel'
      ..type = 'expense'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now().toUtc(),

    CategoryModel()
      ..uuid = defaultUuid
      ..name = 'Medical'
      ..type = 'expense'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now().toUtc(),

    CategoryModel()
      ..uuid = defaultUuid
      ..name = 'Salary'
      ..type = 'income'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now().toUtc(),

    CategoryModel()
      ..uuid = defaultUuid
      ..name = 'Freelance'
      ..type = 'income'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now().toUtc(),
  ];

  // ==========================================
  // DEFAULT ACCOUNTS
  // ==========================================

  static List<AccountModel> accounts = [

    AccountModel()
      ..uuid = defaultUuid
      ..name = 'Cash'
      ..type = 'cash'
      ..currentBalance = 0
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now().toUtc(),

    AccountModel()
      ..uuid = defaultUuid
      ..name = 'Bank Account'
      ..type = 'bank'
      ..currentBalance = 0
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now().toUtc(),

    AccountModel()
      ..uuid = defaultUuid
      ..name = 'Credit Card'
      ..type = 'credit_card'
      ..currentBalance = 0
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now().toUtc(),
  ];
}
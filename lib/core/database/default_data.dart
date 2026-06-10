import '../../shared/models/account_model.dart';
import '../../shared/models/category_model.dart';

class DefaultData {

  // ==========================================
  // DEFAULT CATEGORY UUIDS
  // ==========================================

  static const foodCategoryUuid =
      '11111111-1111-1111-1111-111111111111';

  static const shoppingCategoryUuid =
      '22222222-2222-2222-2222-222222222222';

  static const fuelCategoryUuid =
      '33333333-3333-3333-3333-333333333333';

  static const medicalCategoryUuid =
      '44444444-4444-4444-4444-444444444444';

  static const salaryCategoryUuid =
      '55555555-5555-5555-5555-555555555555';

  static const freelanceCategoryUuid =
      '66666666-6666-6666-6666-666666666666';

  // ==========================================
  // DEFAULT ACCOUNT UUIDS
  // ==========================================

  static const cashAccountUuid =
      'aaaaaaaa-1111-1111-1111-111111111111';

  static const bankAccountUuid =
      'bbbbbbbb-2222-2222-2222-222222222222';

  static const creditCardAccountUuid =
      'cccccccc-3333-3333-3333-333333333333';

  // ==========================================
  // DEFAULT CATEGORIES
  // ==========================================

  static List<CategoryModel> categories = [

    CategoryModel()
      ..uuid = foodCategoryUuid
      ..name = 'Food'
      ..type = 'expense'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    CategoryModel()
      ..uuid = shoppingCategoryUuid
      ..name = 'Shopping'
      ..type = 'expense'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    CategoryModel()
      ..uuid = fuelCategoryUuid
      ..name = 'Fuel'
      ..type = 'expense'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    CategoryModel()
      ..uuid = medicalCategoryUuid
      ..name = 'Medical'
      ..type = 'expense'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    CategoryModel()
      ..uuid = salaryCategoryUuid
      ..name = 'Salary'
      ..type = 'income'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    CategoryModel()
      ..uuid = freelanceCategoryUuid
      ..name = 'Freelance'
      ..type = 'income'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),
  ];

  // ==========================================
  // DEFAULT ACCOUNTS
  // ==========================================

  static List<AccountModel> accounts = [

    AccountModel()
      ..uuid = cashAccountUuid
      ..name = 'Cash'
      ..type = 'cash'
      ..currentBalance = 0
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    AccountModel()
      ..uuid = bankAccountUuid
      ..name = 'Bank Account'
      ..type = 'bank'
      ..currentBalance = 0
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    AccountModel()
      ..uuid = creditCardAccountUuid
      ..name = 'Credit Card'
      ..type = 'credit_card'
      ..currentBalance = 0
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),
  ];
}
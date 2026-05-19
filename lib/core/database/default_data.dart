import '../../shared/models/account_model.dart';
import '../../shared/models/category_model.dart';

class DefaultData {

  static List<CategoryModel> categories = [

    CategoryModel()
      ..name = 'Food'
      ..type = 'expense'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    CategoryModel()
      ..name = 'Shopping'
      ..type = 'expense'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    CategoryModel()
      ..name = 'Fuel'
      ..type = 'expense'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    CategoryModel()
      ..name = 'Medical'
      ..type = 'expense'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    CategoryModel()
      ..name = 'Salary'
      ..type = 'income'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    CategoryModel()
      ..name = 'Freelance'
      ..type = 'income'
      ..isDefault = true
      ..isSynced = false
      ..updatedAt = DateTime.now(),
  ];

  static List<AccountModel> accounts = [

    AccountModel()
      ..name = 'Cash'
      ..type = 'cash'
      ..currentBalance = 0
      ..isSynced = false
      ..updatedAt = DateTime.now(),

    AccountModel()
      ..name = 'Bank Account'
      ..type = 'bank'
      ..currentBalance = 0
      ..isSynced = false
      ..updatedAt = DateTime.now(),
  ];
}
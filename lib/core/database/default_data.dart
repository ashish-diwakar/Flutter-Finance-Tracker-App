import '../../shared/models/account_model.dart';
import '../../shared/models/category_model.dart';

class DefaultData {

  static List<CategoryModel> categories = [

    CategoryModel()
      ..name = 'Food'
      ..type = 'expense'
      ..isDefault = true,

    CategoryModel()
      ..name = 'Shopping'
      ..type = 'expense'
      ..isDefault = true,

    CategoryModel()
      ..name = 'Fuel'
      ..type = 'expense'
      ..isDefault = true,

    CategoryModel()
      ..name = 'Medical'
      ..type = 'expense'
      ..isDefault = true,

    CategoryModel()
      ..name = 'Salary'
      ..type = 'income'
      ..isDefault = true,

    CategoryModel()
      ..name = 'Freelance'
      ..type = 'income'
      ..isDefault = true,
  ];

  static List<AccountModel> accounts = [

    AccountModel()
      ..name = 'Cash'
      ..type = 'cash'
      ..currentBalance = 0,

    AccountModel()
      ..name = 'Bank Account'
      ..type = 'bank'
      ..currentBalance = 0,
  ];
}
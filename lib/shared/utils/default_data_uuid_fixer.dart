import 'package:finance_tracker/shared/models/account_model.dart';
import 'package:finance_tracker/shared/models/category_model.dart';
import 'package:uuid/uuid.dart';


const defaultUuid =
      '11111111-1111-1111-1111-111111111111';
      
List<CategoryModel> fixUuidForCategoryList(List<CategoryModel> categories) {

  for (var category in categories) {
    if (category.uuid == defaultUuid) {
      category.uuid = const Uuid().v4();
    }
  }
  return categories;
}

List<AccountModel> fixUuidForAccountList(List<AccountModel> accounts) {

  for (var account in accounts) {
    if (account.uuid == defaultUuid) {
      account.uuid = const Uuid().v4();
    }
  }
  return accounts;
}
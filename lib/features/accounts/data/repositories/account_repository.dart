import 'package:isar/isar.dart';

import '../../../../shared/models/account_model.dart';

class AccountRepository {

  final Isar isar;

  AccountRepository(this.isar);

  Future<List<AccountModel>> getAccounts() async {

    return await isar.accountModels
        .where()
        .findAll();
  }
}
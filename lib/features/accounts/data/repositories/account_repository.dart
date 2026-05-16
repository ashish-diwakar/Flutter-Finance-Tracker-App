import 'package:isar/isar.dart';

import '../../../../shared/models/account_model.dart';

class AccountRepository {
  final Isar isar;

  AccountRepository(this.isar);

  Future<void> addAccount(AccountModel account) async {
    await isar.writeTxn(() async {
      await isar.accountModels.put(account);
    });
  }

  Future<List<AccountModel>> getAccounts() async {
    return await isar.accountModels.where().findAll();
  }
}
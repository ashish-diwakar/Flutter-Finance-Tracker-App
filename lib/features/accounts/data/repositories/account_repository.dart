import 'package:isar/isar.dart';

import '../../../../shared/models/account_model.dart';

class AccountRepository {

  final Isar isar;

  AccountRepository(this.isar);

  Future<List<AccountModel>>
      getAccounts() async {

    return await isar.accountModels
        .where()
        .findAll();
  }

  Future<void> addAccount(
    AccountModel account,
  ) async {

    await isar.writeTxn(() async {

      await isar.accountModels.put(
        account,
      );
    });
  }

  Future<void> updateAccount(
    AccountModel account,
  ) async {

    account.updatedAt =
        DateTime.now();

    account.isSynced = false;

    await isar.writeTxn(() async {

      await isar.accountModels.put(
        account,
      );
    });
  }

  Future<void> deleteAccount(
    int id,
  ) async {

    await isar.writeTxn(() async {

      await isar.accountModels.delete(
        id,
      );
    });
  }
}
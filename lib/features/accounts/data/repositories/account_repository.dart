import 'package:isar_community/isar.dart';

import '../../../../shared/models/account_model.dart';

class AccountRepository {

  final Isar isar;

  AccountRepository(this.isar);

  Future<List<AccountModel>>
      getAccounts() async {

    return await isar.accountModels
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
  }

  Future<void> addAccount(
    AccountModel account,
  ) async {

    await isar.writeTxn(() async {
      account.updatedAt =
          DateTime.now().toUtc();

      account.isSynced =
          false;
      await isar.accountModels.put(
        account,
      );
    });
  }

  Future<void> updateAccount(
    AccountModel account,
  ) async {

    account.updatedAt =
        DateTime.now().toUtc();

    account.isSynced = false;

    await isar.writeTxn(() async {

      await isar.accountModels.put(
        account,
      );
    });
  }

  // Future<void> deleteAccount(
  //   int id,
  // ) async {

  //   final account =
  //       await isar.accountModels.get(id);

  //   if (account != null &&
  //       account.isDefault) {

  //     throw StateError(
  //       'Default accounts cannot be deleted.',
  //     );
  //   }

  //   await isar.writeTxn(() async {

  //     await isar.accountModels.delete(
  //       id,
  //     );
  //   });
  // }

  Future<void> deleteAccount(
    AccountModel account,
  )
  async {

    if (account.isDefault) {

      throw StateError(
        'Default accounts cannot be deleted.',
      );
    }

    account.isDeleted = true;

    account.isSynced = false;

    account.updatedAt =
        DateTime.now().toUtc();

    await isar.writeTxn(() async {

      await isar.accountModels.put(
        account,
      );
    });
  }
}
import '../../../../shared/models/account_model.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../transactions/domain/services/transaction_effect_service.dart';

class AccountBalanceService {
  static int calculate({
    required AccountModel account,
    required Iterable<TransactionModel> transactions,
  }) {
    var balance = account.currentBalance;

    for (final transaction in transactions) {
      if (transaction.isDeleted) {
        continue;
      }

      balance += TransactionEffectService.effectForAccount(
        transactionType: transaction.type,
        amount: transaction.amount,
        transactionAccountId: transaction.accountId,
        accountId: account.uuid,
        toAccountId: transaction.toAccountId,
      );
    }

    return balance;
  }
}

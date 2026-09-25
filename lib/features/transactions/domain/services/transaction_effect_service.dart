class TransactionEffectService {
  static int effectForAccount({
    required String transactionType,
    required int amount,
    required String transactionAccountId,
    required String accountId,
    String? toAccountId,
  }) {
    switch (transactionType) {
      case 'income':
      case 'borrowed':
      case 'repaymentReceived':
        return transactionAccountId == accountId ? amount : 0;

      case 'expense':
      case 'lent':
      case 'repaymentPaid':
        return transactionAccountId == accountId ? -amount : 0;

      case 'transfer':
        if (transactionAccountId == toAccountId) {
          return 0;
        }

        if (transactionAccountId == accountId) {
          return -amount;
        }

        if (toAccountId == accountId) {
          return amount;
        }

        return 0;

      default:
        return 0;
    }
  }
}
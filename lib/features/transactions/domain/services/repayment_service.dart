import '../../../../shared/models/transaction_model.dart';

class RepaymentService {
  static int getOutstandingAmount({
    required TransactionModel originalTransaction,
    required Iterable<TransactionModel> transactions,
  }) {
    final originalType = originalTransaction.type;

    if (originalType != 'borrowed' &&
        originalType != 'lent') {
      throw ArgumentError(
        'Only borrowed or lent transactions can have repayments.',
      );
    }

    final repaymentType =
        originalType == 'borrowed'
            ? 'repaymentPaid'
            : 'repaymentReceived';

    var repaidAmount = 0;

    for (final transaction in transactions) {
      if (transaction.isDeleted) {
        continue;
      }

      if (transaction.relatedTransactionId !=
          originalTransaction.uuid) {
        continue;
      }

      if (transaction.type != repaymentType) {
        continue;
      }

      repaidAmount += transaction.amount;
    }

    final outstanding =
        originalTransaction.amount - repaidAmount;

    return outstanding > 0 ? outstanding : 0;
  }

  static bool isFullyRepaid({
    required TransactionModel originalTransaction,
    required Iterable<TransactionModel> transactions,
  }) {
    return getOutstandingAmount(
          originalTransaction: originalTransaction,
          transactions: transactions,
        ) ==
        0;
  }

  static String repaymentTypeFor(
    TransactionModel originalTransaction,
  ) {
    switch (originalTransaction.type) {
      case 'borrowed':
        return 'repaymentPaid';

      case 'lent':
        return 'repaymentReceived';

      default:
        throw ArgumentError(
          'Only borrowed or lent transactions can have repayments.',
        );
    }
  }
}
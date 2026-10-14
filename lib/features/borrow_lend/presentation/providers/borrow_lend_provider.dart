import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

enum BorrowLendStatus {
  active,
  dueSoon,
  overdue,
  settled,
}

class BorrowLendItem {
  final TransactionModel transaction;
  final int repaidAmount;
  final int outstandingAmount;

  const BorrowLendItem({
    required this.transaction,
    required this.repaidAmount,
    required this.outstandingAmount,
  });

  bool get isBorrowed =>
      transaction.type == 'borrowed';

  bool get isLent =>
      transaction.type == 'lent';

  bool get isSettled =>
      outstandingAmount <= 0;

  BorrowLendStatus status({
    DateTime? now,
  }) {
    if (isSettled) {
      return BorrowLendStatus.settled;
    }

    final dueDate =
        transaction.dueDate;

    if (dueDate == null) {
      return BorrowLendStatus.active;
    }

    final current =
        (now ?? DateTime.now()).toLocal();

    final today = DateTime(
      current.year,
      current.month,
      current.day,
    );

    final localDueDate =
        dueDate.toLocal();

    final dueDay = DateTime(
      localDueDate.year,
      localDueDate.month,
      localDueDate.day,
    );

    if (dueDay.isBefore(today)) {
      return BorrowLendStatus.overdue;
    }

    final dueSoonLimit =
        today.add(
      const Duration(
        days: 3,
      ),
    );

    if (!dueDay.isAfter(
      dueSoonLimit,
    )) {
      return BorrowLendStatus.dueSoon;
    }

    return BorrowLendStatus.active;
  }
}



class BorrowLendOverview {
  final List<BorrowLendItem> borrowed;
  final List<BorrowLendItem> lent;

  const BorrowLendOverview({
    required this.borrowed,
    required this.lent,
  });

  int get totalOwed {
    return borrowed.fold(
      0,
      (
        total,
        item,
      ) =>
          total + item.outstandingAmount,
    );
  }

  int get totalReceivable {
    return lent.fold(
      0,
      (
        total,
        item,
      ) =>
          total + item.outstandingAmount,
    );
  }

  int get actionableCount {
    final now =
        DateTime.now();

    return [
      ...borrowed,
      ...lent,
    ].where(
      (item) {
        final itemStatus =
            item.status(
          now: now,
        );

        return itemStatus ==
                BorrowLendStatus.dueSoon ||
            itemStatus ==
                BorrowLendStatus.overdue;
      },
    ).length;
  }

}

final borrowLendOverviewProvider =
    Provider<
        AsyncValue<
            BorrowLendOverview>>(
  (ref) {
    final transactionsAsync =
        ref.watch(
      transactionsStreamProvider,
    );

    return transactionsAsync.whenData(
      (transactions) {
        final activeTransactions =
            transactions
                .where(
                  (transaction) =>
                      !transaction.isDeleted,
                )
                .toList();

        final borrowed =
            <BorrowLendItem>[];

        final lent =
            <BorrowLendItem>[];

        for (final transaction
            in activeTransactions) {
          if (transaction.type !=
                  'borrowed' &&
              transaction.type !=
                  'lent') {
            continue;
          }

          final repaymentType =
              transaction.type ==
                      'borrowed'
                  ? 'repaymentPaid'
                  : 'repaymentReceived';

          var repaidAmount = 0;

          for (final repayment
              in activeTransactions) {
            if (repayment
                    .relatedTransactionId !=
                transaction.uuid) {
              continue;
            }

            if (repayment.type !=
                repaymentType) {
              continue;
            }

            repaidAmount +=
                repayment.amount;
          }

          final remaining =
              transaction.amount -
                  repaidAmount;

          final item =
              BorrowLendItem(
            transaction:
                transaction,
            repaidAmount:
                repaidAmount,
            outstandingAmount:
                remaining > 0
                    ? remaining
                    : 0,
          );

          if (transaction.type ==
              'borrowed') {
            borrowed.add(item);
          } else {
            lent.add(item);
          }
        }

        return BorrowLendOverview(
          borrowed: borrowed,
          lent: lent,
        );
      },
    );
  },
);
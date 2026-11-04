
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../providers/transaction_summary_provider.dart';

class TransactionSummaryCard extends ConsumerWidget {
  const TransactionSummaryCard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final summaryAsync = ref.watch(
      transactionSummaryProvider,
    );

    return summaryAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Unable to calculate summary.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),
      data: (summary) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SummaryItem(
                  title: 'Income',
                  value: CurrencyFormatter.format(
                    amount: summary.income,
                    currency: currency,
                  ),
                  icon: Icons.south_west_rounded,
                  color: const Color(0xFF087449),
                  gradientStart: const Color(0xFFB0E6CA),
                  gradientEnd: const Color(0xFFE4F9ED),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SummaryItem(
                  title: 'Expense',
                  value: CurrencyFormatter.format(
                    amount: summary.expense,
                    currency: currency,
                  ),
                  icon: Icons.north_east_rounded,
                  color: const Color(0xFFB12C38),
                  gradientStart: const Color(0xFFFFC5C5),
                  gradientEnd: const Color(0xFFFFEBE8),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SummaryItem(
                  title: 'Net Change',
                  value: CurrencyFormatter.format(
                    amount: summary.balance,
                    currency: currency,
                  ),
                  icon: Icons.account_balance_wallet_outlined,
                  color: summary.balance >= 0
                      ? const Color(0xFF17679F)
                      : const Color(0xFFB56B13),
                  gradientStart: summary.balance >= 0
                      ? const Color(0xFFBDE1F8)
                      : const Color(0xFFFFDDAF),
                  gradientEnd: summary.balance >= 0
                      ? const Color(0xFFEAF7FF)
                      : const Color(0xFFFFF4E3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color gradientStart;
  final Color gradientEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        9,
        10,
        9,
        10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientStart,
            gradientEnd,
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.85,
          ),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(
              alpha: 0.10,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.65,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF425B51),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 22,
            child: Tooltip(
              message: value,
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

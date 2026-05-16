import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/transaction_model.dart';
import '../providers/transaction_repository_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {

  final amountController = TextEditingController();

  final notesController = TextEditingController();

  String transactionType = 'expense';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            DropdownButton<String>(
              value: transactionType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'income',
                  child: Text('Income'),
                ),
                DropdownMenuItem(
                  value: 'expense',
                  child: Text('Expense'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  transactionType = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                final amount =
                    (double.parse(amountController.text) * 100).toInt();

                final repository =
                    await ref.read(
                      transactionRepositoryProvider.future,
                    );

                final transaction = TransactionModel()
                  ..amount = amount
                  ..type = transactionType
                  ..transactionDate = DateTime.now()
                  ..categoryId = 1
                  ..accountId = 1
                  ..notes = notesController.text;

                await repository.addTransaction(transaction);

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
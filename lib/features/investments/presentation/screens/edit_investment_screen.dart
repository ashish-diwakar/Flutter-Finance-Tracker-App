import 'package:flutter/material.dart';

import '../../../../core/database/isar_service.dart';
import '../../../../shared/models/investment_model.dart';

class EditInvestmentScreen extends StatefulWidget {

  final InvestmentModel investment;

  const EditInvestmentScreen({
    super.key,
    required this.investment,
  });

  @override
  State<EditInvestmentScreen> createState() =>
      _EditInvestmentScreenState();
}

class _EditInvestmentScreenState
    extends State<EditInvestmentScreen> {

  final _formKey =
      GlobalKey<FormState>();

  late TextEditingController
      nameController;

  late TextEditingController
      symbolController;

  late TextEditingController
      quantityController;

  late TextEditingController
      purchasePriceController;

  late TextEditingController
      currentPriceController;

  late TextEditingController
      notesController;

  late TextEditingController
      interestRateController;

  late TextEditingController
      maturityValueController;

  late String selectedType;

  late String investmentClass;

  DateTime? maturityDate;

  bool isSaving = false;

  @override
  void initState() {

    super.initState();

    final investment =
        widget.investment;

    selectedType =
        investment.type;

    investmentClass =
        investment.investmentClass;

    maturityDate =
        investment.maturityDate;

    nameController =
        TextEditingController(
      text: investment.name,
    );

    symbolController =
        TextEditingController(
      text:
          investment.symbol ??
              '',
    );

    quantityController =
        TextEditingController(
      text:
          investment.quantity
              .toString(),
    );

    purchasePriceController =
        TextEditingController(
      text:
          (investment.purchasePrice /
                  100)
              .toString(),
    );

    currentPriceController =
        TextEditingController(
      text:
          (investment.currentPrice /
                  100)
              .toString(),
    );

    notesController =
        TextEditingController(
      text:
          investment.notes ??
              '',
    );

    interestRateController =
        TextEditingController(
      text:
          investment.interestRate
                  ?.toString() ??
              '',
    );

    maturityValueController =
        TextEditingController(
      text:
          investment.maturityValue ==
                  null
              ? ''
              : (investment
                          .maturityValue! /
                      100)
                  .toString(),
    );
  }

  @override
  void dispose() {

    nameController.dispose();
    symbolController.dispose();
    quantityController.dispose();
    purchasePriceController.dispose();
    currentPriceController.dispose();
    notesController.dispose();
    interestRateController.dispose();
    maturityValueController.dispose();

    super.dispose();
  }

  bool get isFixedReturn {

    return [
      'FD',
      'RD',
      'PPF',
      'EPF',
      'NPS',
      'Bond',
    ].contains(
      selectedType,
    );
  }

  Future<void>
      updateInvestment()
  async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      final isar =
          await IsarService
              .openIsar();

      final investment =
          widget.investment;

      investment.name =
          nameController.text
              .trim();

      investment.type =
          selectedType;

      investment.symbol =
          symbolController.text
                  .trim()
                  .isEmpty
              ? null
              : symbolController.text
                  .trim();

      investment.notes =
          notesController.text
                  .trim()
                  .isEmpty
              ? null
              : notesController.text
                  .trim();

      investment.investmentClass =
          isFixedReturn
              ? 'fixed'
              : 'market';

      if (isFixedReturn) {

        investment.interestRate =
            double.tryParse(
          interestRateController
              .text,
        );

        investment.maturityDate =
            maturityDate;

        investment.maturityValue =
            maturityValueController
                    .text
                    .trim()
                    .isEmpty
                ? null
                : (double.parse(
                            maturityValueController
                                .text,
                          ) *
                        100)
                    .round();
      } else {

        investment.quantity =
            int.parse(
          quantityController.text,
        );

        investment.purchasePrice =
            (double.parse(
                        purchasePriceController
                            .text,
                      ) *
                    100)
                .round();

        investment.currentPrice =
            (double.parse(
                        currentPriceController
                            .text,
                      ) *
                    100)
                .round();
      }

      investment.updatedAt =
          DateTime.now();

      investment.isSynced =
          false;

      await isar.writeTxn(
        () async {

          await isar
              .investmentModels
              .put(
                investment,
              );
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );

    } finally {

      if (mounted) {

        setState(() {

          isSaving = false;
        });
      }
    }
  }

  Future<void>
      deleteInvestment()
  async {

    final confirmed =
        await showDialog<bool>(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text(
            'Delete Investment',
          ),

          content:
              const Text(
            'Are you sure?',
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                  context,
                  false,
                );
              },

              child: const Text(
                'Cancel',
              ),
            ),

            FilledButton(

              onPressed: () {

                Navigator.pop(
                  context,
                  true,
                );
              },

              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final isar =
        await IsarService
            .openIsar();

    final investment =
        widget.investment;

    investment.isDeleted =
        true;

    investment.isSynced =
        false;

    investment.updatedAt =
        DateTime.now();

    await isar.writeTxn(
      () async {

        await isar
            .investmentModels
            .put(
              investment,
            );
      },
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(
      context,
      true,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Edit Investment',
        ),

        actions: [

          IconButton(

            icon: const Icon(
              Icons.delete_outline,
            ),

            onPressed:
                deleteInvestment,
          ),
        ],
      ),

      body: Form(

        key: _formKey,

        child: ListView(

          padding:
              const EdgeInsets.all(
            16,
          ),

          children: [

            TextFormField(

              controller:
                  nameController,

              decoration:
                  const InputDecoration(
                labelText:
                    'Name',
              ),

              validator:
                  (value) {

                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {

                  return 'Required';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 16,
            ),

            if (!isFixedReturn)
              ...[

                TextFormField(

                  controller:
                      quantityController,

                  keyboardType:
                      TextInputType
                          .number,

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Quantity',
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(

                  controller:
                      purchasePriceController,

                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Purchase Price',
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(

                  controller:
                      currentPriceController,

                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Latest Price',
                  ),
                ),
              ]

            else
              ...[

                TextFormField(

                  controller:
                      interestRateController,

                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Interest Rate (%)',
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(

                  controller:
                      maturityValueController,

                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Maturity Value',
                  ),
                ),
              ],

            const SizedBox(
              height: 16,
            ),

            TextFormField(

              controller:
                  notesController,

              maxLines: 3,

              decoration:
                  const InputDecoration(
                labelText:
                    'Notes',
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            FilledButton(

              onPressed:
                  isSaving
                      ? null
                      : updateInvestment,

              child: Text(

                isSaving
                    ? 'Saving...'
                    : 'Update Investment',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
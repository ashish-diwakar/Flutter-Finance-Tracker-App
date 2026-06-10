import 'package:finance_tracker/shared/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/isar_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/models/investment_model.dart';
import '../../domain/constants/investment_types.dart';
import '../../core/investment_calculator.dart';
import '../../domain/utils/investment_helper.dart';

class EditInvestmentScreen extends ConsumerStatefulWidget {

  final InvestmentModel investment;

  const EditInvestmentScreen({
    super.key,
    required this.investment,
  });

  @override
  ConsumerState<EditInvestmentScreen> createState() =>
      _EditInvestmentScreenState();
}

class _EditInvestmentScreenState
    extends ConsumerState<EditInvestmentScreen> {

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

  late String selectedType;

  DateTime? maturityDate;
  

  int calculateEstimatedMaturityValue() {
     if (!requiresInterestRate) {
      return 0;
    }

    if (!InvestmentHelper.supportsAutoMaturityCalculation(
        selectedType,
    )) {

      return 0;
    }

    if (maturityDate == null) {
      return 0;
    }

    final principal =

        double.tryParse(
          purchasePriceController.text,
        ) ??
        0;

    final rate =

        double.tryParse(
          interestRateController.text,
        ) ??
        0;

    return InvestmentCalculator
            .calculateFdMaturityValue(

          principalAmount:
              (principal * 100)
                  .round(),

          interestRate:
              rate,

          purchaseDate:
              widget
                  .investment
                  .purchaseDate,

          maturityDate:
              maturityDate!,
        ) ??
        0;
  }

  bool isSaving = false;

  void _refreshEstimatedValue() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {

    super.initState();

    final investment =
        widget.investment;

    selectedType =
        investment.type;

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

    purchasePriceController
        .addListener(
      _refreshEstimatedValue,
    );

    interestRateController
        .addListener(
      _refreshEstimatedValue,
    );

  }

  @override
  void dispose() {

    purchasePriceController
        .removeListener(
      _refreshEstimatedValue,
    );

    interestRateController
        .removeListener(
      _refreshEstimatedValue,
    );

    nameController.dispose();
    symbolController.dispose();
    quantityController.dispose();
    purchasePriceController.dispose();
    currentPriceController.dispose();
    notesController.dispose();
    interestRateController.dispose();

    super.dispose();
  }

  bool get isFixedReturn {

  return InvestmentHelper
        .isFixedReturn(
      selectedType,
    );
  }

  bool get requiresInterestRate {

    return InvestmentHelper
        .requiresInterestRate(
      selectedType,
    );
  }

  Future<void>
      selectMaturityDate()
  async {

    final picked =
        await showDatePicker(

      context: context,

      initialDate:
          maturityDate ??
          DateTime.now(),

      firstDate:
          DateTime.now(),

      lastDate:
          DateTime(2100),
    );

    if (picked != null) {

      setState(() {

        maturityDate =
            picked;
      });
    }
  }

  Future<void>
      updateInvestment()
  async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (isFixedReturn &&
        maturityDate == null) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            'Please select maturity date',
          ),
        ),
      );

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

      investment.uuid =
          investment.uuid.isNotEmpty
              ? investment.uuid
              : const Uuid().v4();

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

        final principalAmount =

            ((double.parse(
                          purchasePriceController
                              .text,
                        )) *
                    100)
                .round();

        investment.quantity = 1;

        investment.purchasePrice =
            principalAmount;

        investment.currentPrice =
            principalAmount;

        investment.interestRate =
          requiresInterestRate

              ? double.tryParse(
                  interestRateController.text,
                )

              : null;

        investment.maturityDate =
            maturityDate;

        if (InvestmentHelper
                .supportsAutoMaturityCalculation(
              selectedType,
            )) {

          investment.maturityValue =
              InvestmentCalculator
                  .calculateFdMaturityValue(

                principalAmount:
                    principalAmount,

                interestRate:
                    double.parse(
                      interestRateController.text,
                    ),

                purchaseDate:
                    investment.purchaseDate,

                maturityDate:
                    maturityDate!,
              );

        } else {

          investment.maturityValue =
              null;
        }
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

        // Clear fixed-return fields

        investment.interestRate =
            null;

        investment.maturityDate =
            null;

        investment.maturityValue =
            null;
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

    final currency =
    ref.watch(
      currencyProvider,
    );

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

            DropdownButtonFormField<String>(

              value:
              investmentTypes.contains(
                  selectedType,
                )
              ? selectedType
              : null,

              decoration:
                  const InputDecoration(

                labelText:
                    'Investment Type',
              ),

              items:
                  investmentTypes.map(
                (type) {

                  return DropdownMenuItem(

                    value:
                        type,

                    child:
                        Text(type),
                  );
                },
              ).toList(),

              onChanged: (value) {

                if (value == null) {
                  return;
                }

                setState(() {

                  selectedType = value;

                  if (!InvestmentHelper
                          .requiresInterestRate(
                        value,
                      )) {

                    interestRateController
                        .clear();
                  }

                  // if (InvestmentHelper
                  //         .isFixedReturn(
                  //       value,
                  //     )) {

                  //   quantityController
                  //       .clear();

                  //   currentPriceController
                  //       .clear();
                  // }

                  if (!InvestmentHelper
                          .isFixedReturn(
                        value,
                      )) {

                    maturityDate = null;

                    interestRateController
                        .clear();
                        
                    _refreshEstimatedValue();
                  }
                });
              },
            ),

            const SizedBox(
              height: 16,
            ),

            if (!isFixedReturn)
              ...[

                TextFormField(

                  controller:
                      symbolController,

                  decoration:
                      const InputDecoration(

                    labelText:
                        'Symbol (Optional)',
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

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

                  validator: (value) {

                    if (value == null ||
                        value.trim().isEmpty) {

                      return 'Enter quantity';
                    }

                    if (int.tryParse(value) ==
                        null) {

                      return 'Invalid quantity';
                    }

                    return null;
                  },
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

                  validator: (value) {

                    if (value == null ||
                        value.trim().isEmpty) {

                      return 'Enter purchase price';
                    }

                    if (double.tryParse(value) ==
                        null) {

                      return 'Invalid amount';
                    }

                    return null;
                  },
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

                  validator: (value) {

                    if (value == null ||
                        value.trim().isEmpty) {

                      return 'Enter latest price';
                    }

                    if (double.tryParse(value) ==
                        null) {

                      return 'Invalid amount';
                    }

                    return null;
                  },
                ),
              ]

            else
            ...[

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
                      'Principal Amount',
                ),

                validator: (value) {

                  if (value == null ||
                      value.trim().isEmpty) {

                    return 'Enter principal amount';
                  }

                  if (double.tryParse(value) ==
                      null) {

                    return 'Invalid amount';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              if (requiresInterestRate)
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

                  validator: (value) {

                    if (value == null ||
                        value.trim().isEmpty) {

                      return 'Enter interest rate';
                    }

                    if (double.tryParse(
                          value,
                        ) ==
                        null) {

                      return 'Invalid interest rate';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 16,
                ),
              ],

              ListTile(

                contentPadding:
                    EdgeInsets.zero,

                title: const Text(
                  'Maturity Date',
                ),

                subtitle: Text(

                  maturityDate == null

                      ? 'Select maturity date'

                      : DateFormat(
                        'dd MMM yyyy',
                      ).format(
                        maturityDate!,
                      ),
                ),

                trailing: const Icon(
                  Icons.calendar_today,
                ),

                onTap:
                    selectMaturityDate,
              ),

              const SizedBox(
                height: 16,
              ),

              if (InvestmentHelper
                    .supportsAutoMaturityCalculation(
                  selectedType,
                ))
              ListTile(
                contentPadding:
                    EdgeInsets.zero,

                title: const Text(
                  'Estimated Maturity Value',
                ),
                subtitle: Text(
                  CurrencyFormatter.formatDouble(amount:  calculateEstimatedMaturityValue() / 100, currency: currency),
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
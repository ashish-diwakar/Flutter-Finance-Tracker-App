import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/features/investments/domain/utils/investment_helper.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/isar_service.dart';
import '../../../../shared/models/investment_model.dart';

import '../../domain/constants/investment_types.dart';
import '../../core/investment_calculator.dart';
import '../../../../shared/providers/currency_provider.dart';
import '../../../../core/utils/currency_formatter.dart';


class AddInvestmentScreen extends ConsumerStatefulWidget {

  const AddInvestmentScreen({
    super.key,
  });

  @override
  ConsumerState<AddInvestmentScreen>
      createState() =>
          _AddInvestmentScreenState();
}

class _AddInvestmentScreenState
    extends ConsumerState<
        AddInvestmentScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _symbolController =
      TextEditingController();

  final _quantityController =
      TextEditingController();

  final _purchasePriceController =
      TextEditingController();

  final _currentPriceController =
      TextEditingController();

  final _notesController =
      TextEditingController();

  final _interestRateController =
    TextEditingController();

  String selectedType =
      investmentTypes.first;

  DateTime purchaseDate =
      DateTime.now();

  DateTime? maturityDate;

  bool isSaving = false;

  int calculateEstimatedMaturityValue() {

    if (!requiresInterestRate) {
      return 0;
    }

    if (!InvestmentHelper
            .supportsAutoMaturityCalculation(
          selectedType,
        )) {

      return 0;
    }

    if (maturityDate == null) {
      return 0;
    }

    final principal =

        double.tryParse(
          _purchasePriceController.text,
        ) ??
        0;

    final rate =

        double.tryParse(
          _interestRateController.text,
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
              purchaseDate,

          maturityDate:
              maturityDate!,
        ) ??
        0;
  }

  void _refreshEstimatedValue() {
    if (mounted) {

      setState(() {});
    }
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
    
  @override
  void initState() {

    super.initState();

    _purchasePriceController
        .addListener(
      _refreshEstimatedValue,
    );

    _interestRateController
        .addListener(
      _refreshEstimatedValue,
    );
  }

  @override
  void dispose() {

    _purchasePriceController
        .removeListener(
      _refreshEstimatedValue,
    );

    _interestRateController
        .removeListener(
      _refreshEstimatedValue,
    );

    _nameController.dispose();

    _symbolController.dispose();

    _quantityController.dispose();

    _purchasePriceController.dispose();

    _currentPriceController.dispose();

    _notesController.dispose();

    _interestRateController.dispose();

    super.dispose();
  }

  Future<void>
      saveInvestment()
  async {

    if (!_formKey.currentState!
        .validate()) {

      return;
    }

    setState(() {

      isSaving = true;
    });

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

      setState(() {

        isSaving = false;
      });

      return;
    }

    try {

      final isar =
          await IsarService
              .openIsar();

      final investment =
    InvestmentModel()

      ..uuid = const Uuid().v4()

      ..name =
          _nameController.text
              .trim()

      ..type =
          selectedType

      ..symbol =
          _symbolController.text
                  .trim()
                  .isEmpty
              ? null
              : _symbolController.text
                  .trim()

      ..purchaseDate =
          purchaseDate

      ..notes =
          _notesController.text
                  .trim()
                  .isEmpty
              ? null
              : _notesController.text
                  .trim()

      ..investmentClass =
          isFixedReturn
              ? 'fixed'
              : 'market';

      if (isFixedReturn) {

        final principalAmount =

            ((double.parse(
                          _purchasePriceController
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
                  _interestRateController.text,
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
                            _interestRateController
                                .text,
                          ),

                      purchaseDate:
                          purchaseDate,

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
          _quantityController.text,
        );

        investment.purchasePrice =
            ((double.parse(
                          _purchasePriceController
                              .text,
                        )) *
                    100)
                .round();

        investment.currentPrice =
            ((double.parse(
                          _currentPriceController
                              .text,
                        )) *
                    100)
                .round();

        investment.interestRate =
            null;

        investment.maturityDate =
            null;

        investment.maturityValue =
            null;
      }


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

    } catch (e, stackTrace) {

      debugPrint(
        'SAVE INVESTMENT ERROR: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        SnackBar(

          content: Text(
            'Error: $e',
          ),
        ),
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
      selectPurchaseDate()
  async {

    final picked =
        await showDatePicker(

      context: context,

      initialDate:
          purchaseDate,

      firstDate:
          DateTime(2000),

      lastDate:
          DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        purchaseDate =
            picked;
      });
    }
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
          'Add Investment',
        ),
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
                  _nameController,

              decoration:
                  const InputDecoration(

                labelText:
                    'Investment Name',

                border:
                    OutlineInputBorder(),
              ),

              validator:
                  (value) {

                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {

                  return 'Enter investment name';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 16,
            ),

            DropdownButtonFormField<
                String>(

              value:
                  selectedType,

              decoration:
                  const InputDecoration(

                labelText:
                    'Investment Type',

                border:
                    OutlineInputBorder(),
              ),

              items:
                  investmentTypes
                      .map(

                (type) {

                  return DropdownMenuItem(

                    value: type,

                    child: Text(
                      type,
                    ),
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
                          .isFixedReturn(
                        value,
                      )) {

                    maturityDate = null;
                  }

                  if (!InvestmentHelper
                          .requiresInterestRate(
                        value,
                      )) {

                    _interestRateController.clear();
                  }
                });
              },
            ),

            if (!isFixedReturn) ...[

              const SizedBox(
                height: 16,
              ),

              TextFormField(

                controller:
                    _symbolController,

                decoration:
                    const InputDecoration(

                  labelText:
                      'Symbol (Optional)',

                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(
                height: 16,
              ),
            ],

            if (!isFixedReturn) ...[

              TextFormField(

                controller:
                    _quantityController,

                keyboardType:
                    TextInputType.number,

                decoration:
                    const InputDecoration(

                  labelText:
                      'Quantity',

                  border:
                      OutlineInputBorder(),
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
                    _purchasePriceController,

                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),

                decoration:
                    const InputDecoration(

                  labelText:
                      'Purchase Price',

                  border:
                      OutlineInputBorder(),
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
                    _currentPriceController,

                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),

                decoration:
                    const InputDecoration(

                  labelText:
                      'Latest Price',

                  border:
                      OutlineInputBorder(),
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

            ] else ...[

              const SizedBox(
                height: 16,
              ),

              TextFormField(

                controller:
                    _purchasePriceController,

                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),

                decoration:
                    const InputDecoration(

                  labelText:
                      'Principal Amount',

                  border:
                      OutlineInputBorder(),
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
                      _interestRateController,

                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Interest Rate (%)',
                    border:
                        OutlineInputBorder(),
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

                  CurrencyFormatter
                      .formatDouble(

                    amount:
                        calculateEstimatedMaturityValue() /
                        100,

                    currency:
                        currency,
                  ),
                ),
              ),
            ],

            const SizedBox(
              height: 16,
            ),

            ListTile(

              contentPadding:
                  EdgeInsets.zero,

              title: const Text(
                'Purchase Date',
              ),

              subtitle: Text(

                DateFormat(
                    'dd MMM yyyy',
                  ).format(
                    purchaseDate,
                  )
              ),

              trailing: const Icon(
                Icons.calendar_today,
              ),

              onTap:
                  selectPurchaseDate,
            ),

            const SizedBox(
              height: 16,
            ),

            TextFormField(

              controller:
                  _notesController,

              maxLines: 4,

              decoration:
                  const InputDecoration(

                labelText:
                    'Notes (Optional)',

                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            SizedBox(

              height: 52,

              child:
                  FilledButton.icon(

                onPressed:

                    isSaving

                        ? null

                        : saveInvestment,

                icon:

                    isSaving

                        ? const SizedBox(

                            height: 18,

                            width: 18,

                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                            ),
                          )

                        : const Icon(
                            Icons.save,
                          ),

                label: Text(

                  isSaving

                      ? 'Saving...'

                      : 'Save Investment',
                ),
              ),
            ),

            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
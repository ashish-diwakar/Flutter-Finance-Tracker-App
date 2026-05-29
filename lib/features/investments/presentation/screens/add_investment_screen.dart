import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../../../../core/database/isar_service.dart';
import '../../../../shared/models/investment_model.dart';

import '../../domain/constants/investment_types.dart';

class AddInvestmentScreen extends StatefulWidget {

  const AddInvestmentScreen({
    super.key,
  });

  @override
  State<AddInvestmentScreen>
      createState() =>
          _AddInvestmentScreenState();
}

class _AddInvestmentScreenState
    extends State<
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

  String selectedType =
      investmentTypes.first;

  DateTime purchaseDate =
      DateTime.now();

  bool isSaving = false;

  @override
  void dispose() {

    _nameController.dispose();

    _symbolController.dispose();

    _quantityController.dispose();

    _purchasePriceController
        .dispose();

    _currentPriceController
        .dispose();

    _notesController.dispose();

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

    try {

      final isar =
          await IsarService
              .openIsar();

      final investment =
          InvestmentModel()

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

                : _symbolController
                    .text
                    .trim()

            ..quantity =
                int.parse(
              _quantityController
                  .text,
            )

            ..purchasePrice =
                ((double.parse(
                              _purchasePriceController
                                  .text,
                            )) *
                        100)
                    .round()

            ..currentPrice =
                ((double.parse(
                              _currentPriceController
                                  .text,
                            )) *
                        100)
                    .round()

            ..purchaseDate =
                purchaseDate

            ..notes =
                _notesController.text
                    .trim()
                    .isEmpty

                ? null

                : _notesController
                    .text
                    .trim();

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

    } catch (e) {

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
    }

    if (mounted) {

      setState(() {

        isSaving = false;
      });
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

  @override
  Widget build(
    BuildContext context,
  ) {

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

              onChanged:
                  (value) {

                if (value !=
                    null) {

                  setState(() {

                    selectedType =
                        value;
                  });
                }
              },
            ),

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

              validator:
                  (value) {

                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {

                  return 'Enter quantity';
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

              validator:
                  (value) {

                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {

                  return 'Enter purchase price';
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
                    'Current Price',

                border:
                    OutlineInputBorder(),
              ),

              validator:
                  (value) {

                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {

                  return 'Enter current price';
                }

                return null;
              },
            ),

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

                '${purchaseDate.day}/'
                '${purchaseDate.month}/'
                '${purchaseDate.year}',
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
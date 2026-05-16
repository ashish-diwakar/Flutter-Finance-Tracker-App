class TransactionValidator {

  static String? validateAmount(String value) {

    if (value.trim().isEmpty) {
      return 'Amount required';
    }

    final amount = double.tryParse(value);

    if (amount == null) {
      return 'Invalid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }

    return null;
  }
}
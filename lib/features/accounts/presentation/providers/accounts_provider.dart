import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/account_model.dart';
import 'account_repository_provider.dart';

final accountsProvider =
    FutureProvider<List<AccountModel>>((ref) async {

  final repository =
      await ref.watch(
        accountRepositoryProvider.future,
      );

  return repository.getAccounts();
});
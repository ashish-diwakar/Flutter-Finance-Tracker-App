class SyncResult {

  final int successCount;

  final int failedCount;

  final List<String> errors;

  const SyncResult({

    required this.successCount,

    required this.failedCount,

    required this.errors,
  });
}
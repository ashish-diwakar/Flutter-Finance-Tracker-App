class ConflictResolver {

  static bool shouldReplaceLocal({
    required DateTime? localUpdatedAt,
    required DateTime? remoteUpdatedAt,
  }) {

    if (remoteUpdatedAt == null) {
      return false;
    }

    if (localUpdatedAt == null) {
      return true;
    }

    return remoteUpdatedAt.isAfter(
      localUpdatedAt,
    );
  }
}
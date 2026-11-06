import 'package:isar_community/isar.dart';

part 'full_snapshot_restore_marker.g.dart';

/// Device-local seed suppression, committed with the restored snapshot.
@collection
class FullSnapshotRestoreMarker {
  static const singletonId = 1;

  Id id = singletonId;
}

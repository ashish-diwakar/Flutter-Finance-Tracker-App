import 'package:flutter/material.dart';

class TransactionSyncIcon extends StatelessWidget {

  const TransactionSyncIcon({
    super.key,
    required this.isSynced,
    this.size = 18,
  });

  final bool isSynced;

  final double size;

  @override
  Widget build(BuildContext context) {

    final color = isSynced
        ? Colors.green
        : Colors.orange;

    final icon = isSynced
        ? Icons.cloud_done
        : Icons.cloud_off;

    final tooltip = isSynced
        ? 'Synced'
        : 'Pending Sync';

    return Tooltip(

      message: tooltip,

      child: Icon(

        icon,

        size: size,

        color: color,
      ),
    );
  }
}
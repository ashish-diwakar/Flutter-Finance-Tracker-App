
import 'package:flutter/material.dart';

class TransactionSectionHeader extends StatelessWidget {
  final String title;
  final bool auroraStyle;

  const TransactionSectionHeader({
    super.key,
    required this.title,
    this.auroraStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: auroraStyle
          ? const EdgeInsets.fromLTRB(10, 6, 10, 4)
          : const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: auroraStyle
          ? const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            )
          : const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
      decoration: BoxDecoration(
        color: auroraStyle
            ? null
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
        gradient: auroraStyle
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFB4DFCD),
                  Color(0xFFD5EFE3),
                  Color(0xFFF0FAF5),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        border: auroraStyle
            ? Border.all(
                color: Colors.white.withValues(
                  alpha: 0.85,
                ),
                width: 1,
              )
            : null,
        boxShadow: auroraStyle
            ? [
                BoxShadow(
                  color: const Color(0xFF18745D)
                      .withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(
              fontSize: auroraStyle ? 13 : null,
              fontWeight: auroraStyle
                  ? FontWeight.w600
                  : FontWeight.bold,
              color: auroraStyle
                  ? const Color(0xFF155944)
                  : null,
            ),
      ),
    );
  }
}

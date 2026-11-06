import 'package:finance_tracker/core/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/aurora_app_bar.dart';
import '../providers/backup_repository_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _exporting = false;
  bool _savingLocally = false;

  Future<void> _exportBackup({required bool saveLocally}) async {
    if (_exporting) {
      return;
    }

    setState(() {
      _exporting = true;
      _savingLocally = saveLocally;
    });

    try {
      final repository = await ref.read(backupRepositoryProvider.future);
      final saved = saveLocally ? await repository.saveBackupLocally() : null;

      if (!saveLocally) {
        await repository.shareBackup();
      }

      if (!mounted) {
        return;
      }

      if (saveLocally && saved == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Backup saved')));
      } else if (!saveLocally) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup prepared for sharing')),
        );
      }
    } catch (e, stack) {
      LoggerService.error('Export Backup Error: $e');
      LoggerService.error('Export Backup Error: $stack');

      if (mounted) {
        final action = saveLocally ? 'save' : 'prepare backup for sharing';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to $action: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _savingLocally = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuroraAppBar(title: Text('Backup & Restore')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFB6D7CC),
                  Color(0xFFDAEDE5),
                  Color(0xFFF8FCFA),
                ],
                stops: [0.0, 0.52, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Protect Your Financial Data',
                    style: TextStyle(
                      color: Color(0xFF244D40),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Save a complete JSON backup locally or share it, and choose a backup file to import.',
                    style: TextStyle(color: Color(0xFF536B61), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Version 2 backups are plain JSON and can be exported, but importing them requires the upcoming restore update.',
                    style: TextStyle(color: Color(0xFF536B61), fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.zero,
                    color: const Color(0xFFF1F8F2),
                    surfaceTintColor: Colors.transparent,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: Color(0xFFA8CFC0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDFF1E5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.backup_outlined,
                                  color: Color(0xFF237F50),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Export Backup',
                                  style: TextStyle(
                                    color: Color(0xFF244D40),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Create a complete JSON backup of your accounts, categories, transactions, recurring transactions, goals, and investments.',
                            style: TextStyle(
                              color: Color(0xFF536B61),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _exporting
                                  ? null
                                  : () => _exportBackup(saveLocally: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF17664F),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_exporting && _savingLocally)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  else
                                    const Icon(Icons.save_alt_outlined),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _exporting && _savingLocally
                                          ? 'Saving backup...'
                                          : 'Save Backup Locally',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _exporting
                                  ? null
                                  : () => _exportBackup(saveLocally: false),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFF9FCF9),
                                foregroundColor: const Color(0xFF17664F),
                                minimumSize: const Size.fromHeight(52),
                                side: const BorderSide(
                                  color: Color(0xFFA8CFC0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_exporting && !_savingLocally)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF17664F),
                                      ),
                                    )
                                  else
                                    const Icon(Icons.share_outlined),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _exporting && !_savingLocally
                                          ? 'Preparing share...'
                                          : 'Share / Send Backup',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.zero,
                    color: const Color(0xFFF1F8F2),
                    surfaceTintColor: Colors.transparent,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: Color(0xFFA8CFC0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F1E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.file_upload_outlined,
                                  color: Color(0xFF315F53),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Import Backup',
                                  style: TextStyle(
                                    color: Color(0xFF244D40),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Full restore is temporarily unavailable. Version 2 backups can be exported, but importing them requires the upcoming restore update. Older backups are incomplete and cannot be used for full restoration.',
                            style: TextStyle(
                              color: Color(0xFF536B61),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: null,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFF9FCF9),
                                foregroundColor: const Color(0xFF17664F),
                                minimumSize: const Size.fromHeight(52),
                                side: const BorderSide(
                                  color: Color(0xFFA8CFC0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              icon: const Icon(Icons.lock_outline),
                              label: const Text('Restore update coming soon'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

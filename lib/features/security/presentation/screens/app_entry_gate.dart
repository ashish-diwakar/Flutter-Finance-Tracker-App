import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/logger_service.dart';
import '../../../navigation/presentation/screens/main_navigation_screen.dart';
import '../providers/app_lock_enabled_provider.dart';
import '../providers/post_unlock_startup_provider.dart';
import 'app_lock_screen.dart';

class AppEntryGate extends ConsumerWidget {
  const AppEntryGate({super.key, this.unlockedScreen});

  /// Allows isolated widget tests to observe entry without app data.
  final Widget? unlockedScreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockEnabled = ref.watch(appLockEnabledProvider);
    return lockEnabled.when(
      data: (enabled) => enabled
          ? AppLockScreen(unlockedScreen: unlockedScreen)
          : _UnlockedStartupScreen(unlockedScreen: unlockedScreen),
      loading: () => const Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Checking app security…'),
              ],
            ),
          ),
        ),
      ),
      error: (error, stackTrace) =>
          AppLockScreen(unlockedScreen: unlockedScreen),
    );
  }
}

class _UnlockedStartupScreen extends ConsumerStatefulWidget {
  const _UnlockedStartupScreen({this.unlockedScreen});

  final Widget? unlockedScreen;

  @override
  ConsumerState<_UnlockedStartupScreen> createState() =>
      _UnlockedStartupScreenState();
}

class _UnlockedStartupScreenState
    extends ConsumerState<_UnlockedStartupScreen> {
  bool _running = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initialize();
    });
  }

  Future<void> _initialize() async {
    if (_running) return;

    setState(() {
      _running = true;
      _failed = false;
    });

    try {
      await ref.read(postUnlockStartupProvider).run();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => widget.unlockedScreen ?? const MainNavigationScreen(),
        ),
      );
    } catch (e, stackTrace) {
      LoggerService.exception(
        'Application initialization failed',
        e,
        stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _running = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _failed ? Icons.error_outline : Icons.hourglass_empty,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                _failed
                    ? 'Unable to prepare Finance Tracker.'
                    : 'Preparing Finance Tracker…',
                textAlign: TextAlign.center,
              ),
              if (_failed) ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _initialize,
                  child: const Text('Try Again'),
                ),
              ] else ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

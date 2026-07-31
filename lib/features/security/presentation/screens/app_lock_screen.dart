import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../navigation/presentation/screens/main_navigation_screen.dart';
import '../providers/app_lock_provider.dart';

class AppLockScreen extends ConsumerStatefulWidget {

  const AppLockScreen({
    super.key,
  });

  @override
  ConsumerState<AppLockScreen> createState() =>
      _AppLockScreenState();
}

class _AppLockScreenState
    extends ConsumerState<AppLockScreen> {

  bool _loading = false;

  bool _authenticationFailed = false;

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      _authenticate();

    });
  }

  Future<void> _authenticate() async {

    if (_loading) return;

    setState(() {

      _loading = true;

      _authenticationFailed = false;

    });

    final success =
        await ref
            .read(appLockServiceProvider)
            .authenticate();

    if (!mounted) return;

    if (success) {

      Navigator.of(context).pushReplacement(

        MaterialPageRoute(

          builder: (_) =>
              const MainNavigationScreen(),

        ),
      );

      return;
    }

    setState(() {

      _loading = false;

      _authenticationFailed = true;

    });
  }

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    return Scaffold(

      body: SafeArea(

        child: Center(

          child: Padding(

            padding:
                const EdgeInsets.all(24),

            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                Icon(

                  Icons.lock,

                  size: 90,

                  color:
                      theme.colorScheme.primary,
                ),

                const SizedBox(
                  height: 24,
                ),

                Text(

                  "Finance Tracker",

                  style: theme
                      .textTheme
                      .headlineMedium
                      ?.copyWith(

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(

                  "Authenticate to continue",

                  textAlign:
                      TextAlign.center,

                  style: theme
                      .textTheme
                      .bodyLarge,
                ),

                const SizedBox(
                  height: 48,
                ),

                if (_loading)
                  const CircularProgressIndicator(),

                if (_authenticationFailed) ...[

                  const Icon(

                    Icons.lock_open,

                    size: 64,

                    color: Colors.orange,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(

                    "Authentication failed or cancelled.",

                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  FilledButton.icon(

                    onPressed:
                        _authenticate,

                    icon:
                        const Icon(Icons.fingerprint),

                    label:
                        const Text("Try Again"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
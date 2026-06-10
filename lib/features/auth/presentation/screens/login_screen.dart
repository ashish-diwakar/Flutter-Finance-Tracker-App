import 'package:finance_tracker/shared/providers/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../navigation/presentation/screens/main_navigation_screen.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../../../../shared/utils/provider_refresh_helper.dart';

class LoginScreen
    extends ConsumerStatefulWidget {

  const LoginScreen({
    super.key,
  });

  @override
  ConsumerState<LoginScreen>
      createState() =>
          _LoginScreenState();
}

class _LoginScreenState
    extends ConsumerState<LoginScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Login'),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller:
                  emailController,

              decoration:
                  const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  passwordController,

              obscureText: true,

              decoration:
                  const InputDecoration(
                labelText: 'Password',
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: loading
                    ? null
                    : () async {

                        setState(() {
                          loading = true;
                        });

                        try {

                          final auth =
                              ref.read(
                            authServiceProvider,
                          );

                          await auth.signIn(
                            email:
                                emailController
                                    .text,
                            password:
                                passwordController
                                    .text,
                          );

                          ref.invalidate(isarProvider);
                          ref.invalidate(syncServiceProvider);

                          final syncService = await ref.read(
                              syncServiceProvider.future,
                          );

                          await syncService.syncAll();

                          await ProviderRefreshHelper.refreshAllFinancialData(ref);

                          if (mounted) {

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    //const DashboardScreen(),
                                    const MainNavigationScreen(),
                              ),
                            );
                          }

                        } catch (e) {

                          if (mounted) {

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content:
                                    Text(
                                  e.toString(),
                                ),
                              ),
                            );
                          }
                        }

                        if (mounted) {

                          setState(() {
                            loading = false;
                          });
                        }
                      },

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const SignupScreen(),
                  ),
                );
              },
              child: const Text(
                'Create Account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
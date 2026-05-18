import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class SignupScreen
    extends ConsumerStatefulWidget {

  const SignupScreen({
    super.key,
  });

  @override
  ConsumerState<SignupScreen>
      createState() =>
          _SignupScreenState();
}

class _SignupScreenState
    extends ConsumerState<SignupScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
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

                          // await auth.signUp(
                          //   email:
                          //       emailController
                          //           .text,
                          //   password:
                          //       passwordController
                          //           .text,
                          // );

                          // if (mounted) {

                          //   Navigator.pop(
                          //     context,
                          //   );

                          //   ScaffoldMessenger.of(
                          //     context,
                          //   ).showSnackBar(
                          //     const SnackBar(
                          //       content: Text(
                          //         'Verification email sent. Please confirm your email before login.',
                          //       ),
                          //       duration: Duration(
                          //         seconds: 5,
                          //       ),
                          //     ),
                          //   );
                          // }

                          await auth.signUp(
                            email:
                                emailController.text.trim(),
                            password:
                                passwordController.text.trim(),
                          );

                          if (mounted) {

                            await showDialog(
                              context: context,
                              builder: (_) {

                                return AlertDialog(

                                  title: const Text(
                                    'Verify Email',
                                  ),

                                  content: const Text(
                                    'A verification email has been sent.\n\nPlease open your email and click the confirmation link before logging in.',
                                  ),

                                  actions: [

                                    TextButton(
                                      onPressed: () {

                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );

                            Navigator.pop(context);
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
                    : const Text(
                        'Sign Up',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
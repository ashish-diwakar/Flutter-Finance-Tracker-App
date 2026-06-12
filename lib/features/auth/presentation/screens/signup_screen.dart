import 'package:finance_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {

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

  final formKey =
      GlobalKey<FormState>();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool loading = false;

  bool obscurePassword = true;

  bool obscureConfirmPassword = true;

  @override
  void dispose() {

    emailController.dispose();

    passwordController.dispose();

    confirmPasswordController.dispose();

    super.dispose();
  }

  String? validateEmail(
    String? value,
  ) {

    if (value == null ||
        value.trim().isEmpty) {

      return 'Email is required';
    }

    final email =
        value.trim();

    final regex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!regex.hasMatch(email)) {

      return 'Enter a valid email address';
    }

    return null;
  }

  String? validatePassword(
    String? value,
  ) {

    if (value == null ||
        value.isEmpty) {

      return 'Password is required';
    }

    if (value.length < 8) {

      return
          'Password must be at least 8 characters';
    }

    final hasUppercase =
        value.contains(
      RegExp(r'[A-Z]'),
    );

    final hasLowercase =
        value.contains(
      RegExp(r'[a-z]'),
    );

    final hasDigit =
        value.contains(
      RegExp(r'[0-9]'),
    );

    if (!hasUppercase ||
        !hasLowercase ||
        !hasDigit) {

      return
          'Password must contain uppercase, lowercase and number';
    }

    return null;
  }

  String? validateConfirmPassword(
    String? value,
  ) {

    if (value == null ||
        value.isEmpty) {

      return
          'Confirm password is required';
    }

    if (value !=
        passwordController.text) {

      return
          'Passwords do not match';
    }

    return null;
  }

  String mapAuthError(
    dynamic error,
  ) {

    final message =
        error.toString().toLowerCase();

    if (message.contains(
      'user already registered',
    )) {

      return
          'An account already exists with this email';
    }

    if (message.contains(
      'invalid email',
    )) {

      return
          'Please enter a valid email address';
    }

    if (message.contains(
      'password',
    )) {

      return
          'Password does not meet security requirements';
    }

    if (message.contains(
      'network',
    )) {

      return
          'Network error. Please check your internet connection';
    }

    return
        'Unable to create account right now. Please try again later.';
  }

  Future<void> signUp() async {

    FocusScope.of(context)
        .unfocus();

    if (!formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {

      final auth =
          ref.read(
        authServiceProvider,
      );

      await auth.signUp(
        email:
            emailController.text
                .trim(),

        password:
            passwordController.text,
      );

      if (!mounted) {
        return;
      }

      await showDialog(
        context: context,

        barrierDismissible: false,

        builder: (_) {

          return AlertDialog(

            title: const Text(
              'Verify Email',
            ),

            content: const Text(
              'A verification email has been sent.\n\nPlease open your email and click the verification link before logging in.',
            ),

            actions: [

              TextButton(
                onPressed: () {

                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  'OK',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) {
        return;
      }


      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        SnackBar(
          content: Text(
            mapAuthError(e),
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(16),

          child: Form(

            key: formKey,

            child: Column(

              children: [

                TextFormField(

                  controller:
                      emailController,

                  keyboardType:
                      TextInputType
                          .emailAddress,

                  autofillHints:
                      const [
                    AutofillHints.email,
                  ],

                  textInputAction:
                      TextInputAction.next,

                  validator:
                      validateEmail,

                  decoration:
                      const InputDecoration(
                    labelText: 'Email',
                    border:
                        OutlineInputBorder(),
                    prefixIcon:
                        Icon(Icons.email),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(

                  controller:
                      passwordController,

                  obscureText:
                      obscurePassword,

                  autofillHints:
                      const [
                    AutofillHints.password,
                  ],

                  validator:
                      validatePassword,

                  textInputAction:
                      TextInputAction.next,

                  decoration:
                      InputDecoration(
                    labelText:
                        'Password',

                    border:
                        const OutlineInputBorder(),

                    prefixIcon:
                        const Icon(
                      Icons.lock,
                    ),

                    suffixIcon:
                        IconButton(

                      onPressed: () {

                        setState(() {

                          obscurePassword =
                              !obscurePassword;
                        });
                      },

                      icon: Icon(

                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                TextFormField(

                  controller:
                      confirmPasswordController,

                  obscureText:
                      obscureConfirmPassword,

                  validator:
                      validateConfirmPassword,

                  textInputAction:
                      TextInputAction.done,

                  onFieldSubmitted:
                      (_) {

                    if (!loading) {
                      signUp();
                    }
                  },

                  decoration:
                      InputDecoration(
                    labelText:
                        'Confirm Password',

                    border:
                        const OutlineInputBorder(),

                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon:
                        IconButton(

                      onPressed: () {

                        setState(() {

                          obscureConfirmPassword =
                              !obscureConfirmPassword;
                        });
                      },

                      icon: Icon(

                        obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                SizedBox(

                  width: double.infinity,

                  height: 50,

                  child: ElevatedButton(

                    onPressed:
                        loading
                            ? null
                            : signUp,

                    child: loading
                        ? const SizedBox(

                            height: 24,
                            width: 24,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Account',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
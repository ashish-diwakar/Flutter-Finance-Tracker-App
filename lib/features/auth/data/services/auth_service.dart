import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  final supabase =
      Supabase.instance.client;

  Future<void> signUp({
    required String email,
    required String password,
  }) async {

    await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {

    final response =
        await supabase.auth
            .signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception(
        'Login failed',
      );
    }

    if (user.emailConfirmedAt ==
        null) {

      await supabase.auth.signOut();

      throw Exception(
        'Please verify your email before login.',
      );
    }
  }

  Future<void> signOut() async {

    await supabase.auth.signOut();
  }

  User? get currentUser {

    return supabase.auth.currentUser;
  }
}
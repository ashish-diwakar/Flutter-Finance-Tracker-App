import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import '../../../dashboard/presentation/dashboard_screen.dart';
import 'login_screen.dart';
import '../../../security/presentation/screens/biometric_lock_screen.dart';

class AuthGate
    extends StatelessWidget {

  const AuthGate({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final session =
        Supabase.instance.client.auth
            .currentSession;

    if (session != null) {
      // return const DashboardScreen();
      return const BiometricLockScreen();
    }

    return const LoginScreen();

    
      // return Scaffold(
      //   body: FutureBuilder(
      //     // Fetch data from Supabase 'todos' table
      //     future: Supabase.instance.client.from('todos').select('*'),
      //     builder: (context, snapshot) {
      //       if (!snapshot.hasData) {
      //         return const Center(child: CircularProgressIndicator());
      //       }
            
      //       final todos = snapshot.data as List<dynamic>;
            
      //       if(todos.isEmpty) {
      //         return const Center(child: Text('No todos found'));
      //       }

      //       return ListView.builder(
      //         itemCount: todos.length,
      //         itemBuilder: (context, index) {
      //           final todo = todos[index];
      //           return ListTile(
      //             title: Text(todo['name']),
      //           );
      //         },
      //       );
      //     },
      //   ),
      // );
    


  }
}
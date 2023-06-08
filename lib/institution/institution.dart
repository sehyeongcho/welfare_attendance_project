import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:welfare_attendance_project/institution/hompage.dart';
import 'loginpage.dart';

// TODO: Convert ShrineApp to stateful widget (104)
class InstitutionApp extends StatelessWidget {
  const InstitutionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> user) {
          if (user.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (user.hasData) {
            return HomePage();
          } else {
            return LoginPage();
          }
        },
      );

  }
}

// TODO: Build a Shrine Theme (103)
// TODO: Build a Shrine Text Theme (103)

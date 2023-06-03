import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:welfare_attendance_project/teacher/homepage.dart';

import 'courselist.dart';
import 'loginpage.dart';


// TODO: Convert ShrineApp to stateful widget (104)
class TeacherApp extends StatelessWidget {
  const TeacherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> user) {
          if (user.hasData) {
            print('login ok');
            return HomePage();
          } else {
            print('login no');
            return LoginPage();
          }
        },
      );

  }
}

// TODO: Build a Shrine Theme (103)
// TODO: Build a Shrine Text Theme (103)

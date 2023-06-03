import 'package:flutter/material.dart';
import 'package:welfare_attendance_project/institution/institution.dart';
import 'package:welfare_attendance_project/teacher/teacher.dart';
import 'institution/loginpage.dart' as ins;
import 'teacher/loginpage.dart' as tea;
import 'app_state.dart';
import 'package:provider/provider.dart';

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        appState.whatuser = false;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TeacherApp()),
                        );
                      },
                      child: Text('강사용 로그인')),
                  ElevatedButton(
                      onPressed: () {
                        appState.whatuser = true;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InstitutionApp()),
                        );
                      },
                      child: Text('복지사용 로그인'))
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

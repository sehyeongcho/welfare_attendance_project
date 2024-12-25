/**
 Firebase를 초기화하고 앱의 상태를 관리하면서, 기본 테마와 첫 화면(StartPage)을 설정하는 파일입니다.
 */
import 'package:flutter/material.dart'; // Flutter에서 UI를 구성하는 데 필요한 기본적인 위젯과 기능을 제공합니다.
import 'package:firebase_core/firebase_core.dart'; // Firebase 초기화 및 연동을 위한 패키지입니다.
import 'package:welfare_attendance_project/startpage.dart';
import 'firebase_options.dart'; // Firebase 설정 관련 파일을 가져옵니다.
import 'package:provider/provider.dart'; // 상태 관리 패턴을 위한 Provider 패키지입니다.
import 'app_state.dart';
import 'color_schemes.g.dart'; // 색상 테마 관련 설정을 가져옵니다.
import 'package:google_fonts/google_fonts.dart'; // Google Fonts에서 제공하는 다양한 글꼴을 사용할 수 있도록 합니다.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 앱의 비동기 작업을 설정하기 전에 초기화를 보장합니다.
  await Firebase.initializeApp( // Firebase를 초기화합니다.
    options: DefaultFirebaseOptions.currentPlatform, // Firebase 설정 파일을 사용합니다. 플랫폼(Android, iOS 등)에 맞는 Firebase 설정을 자동으로 가져옵니다.
  );

  runApp(ChangeNotifierProvider( // 앱 상태 관리 도구입니다. ApplicationState라는 상태 객체를 생성하여 앱 전체에서 사용할 수 있도록 합니다.
      create: (context) => ApplicationState(), // 앱의 상태를 관리합니다.
      builder: (context, child) {
        return const MyApp(); // MyApp 위젯을 실행합니다.
      }));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        fontFamily: GoogleFonts.nanumGothic().fontFamily,
        textTheme: TextTheme(
          titleLarge: const TextStyle(
            color: Colors.white,
            fontSize: 30.0,
          ),
          titleMedium: TextStyle(
            fontFamily: GoogleFonts.eastSeaDokdo().fontFamily,
            fontSize: 36.0,
          ),
        ),
      ),
      home: const StartPage(), // 앱이 시작될 때 표시할 화면(페이지)입니다.
    );
  }
}

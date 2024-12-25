/**
 앱의 시작 페이지를 정의한 파일입니다. 화면에 배경 영상을 재생하며, 세로 또는 가로 모드에 따라 다른 레이아웃을 표시합니다.
 */
import 'package:flutter/material.dart';
import 'package:welfare_attendance_project/institution/institution.dart';
import 'package:welfare_attendance_project/teacher/teacher.dart';
import 'institution/loginpage.dart' as ins;
import 'teacher/loginpage.dart' as tea;
import 'app_state.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // 비디오 재생을 위한 패키지입니다.
import 'package:animated_text_kit/animated_text_kit.dart'; // 애니메이션 텍스트 표시를 위한 패키지입니다.

class StartPage extends StatefulWidget { // 앱의 시작 화면을 나타냅니다. 상태를 가진 화면을 만들기 위해 StatefulWidget을 사용합니다. (배경 비디오 재생 상태 관리 등)
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState(); // State 클래스에서 StartPage의 동작과 상태를 정의합니다.
}

class _StartPageState extends State<StartPage> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() { // 화면이 처음 생성될 때 한 번 실행되며, 초기화 작업을 수행합니다.
    super.initState();
    _videoPlayerController =
        VideoPlayerController.asset("assets/background.mp4")
          ..initialize().then((_) { // 비디오를 초기화하고 준비가 완료되면 재생을 시작합니다.
            _videoPlayerController.play();
            _videoPlayerController.setLooping(true);
            setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) { // 화면에 표시할 UI를 정의합니다. 비디오 위에 다른 위젯(텍스트, 버튼 등)을 배치합니다. 화면 방향에 따라 세로 모드와 가로 모드로 나뉩니다. 상태 변경 또는 화면 갱신 시마다 다시 호출됩니다.
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait; // 디바이스의 정보를 가져와서 화면이 세로인지 가로인지 확인합니다.

    _videoPlayerController.setVolume(0.0);

    return SafeArea(
      child: Scaffold(
        body: Stack( // 여러 위젯을 겹쳐서 배치합니다. 비디오 배경 위에 텍스트와 버튼을 추가합니다.
          children: <Widget>[
            // 배경 영상
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoPlayerController.value.size.width,
                  height: _videoPlayerController.value.size.height,
                  child: VideoPlayer(_videoPlayerController),
                ),
              ),
            ),

            // 위젯 섹션
            isPortrait ? const StartPagePortrait() : const StartPageLandscape(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() { // 화면이 사라질 때 호출되며, 사용한 리소스를 정리합니다.
    super.dispose();
    _videoPlayerController.dispose(); // 비디오 컨트롤러를 메모리에서 해제합니다.
  }
}

// 위젯 섹션 (세로 화면)
class StartPagePortrait extends StatelessWidget {
  const StartPagePortrait({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>(); // 앱의 상태를 관리합니다.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 84.0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 200.0,
                  height: 200.0,
                  child: AnimatedTextKit( // 애니메이션 효과로 텍스트를 표시합니다.
                    animatedTexts: [
                      TyperAnimatedText(
                        '노인복지시설에\n오신 것을\n환영합니다',
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        speed: const Duration(milliseconds: 250),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 100.0,
              height: 50.0,
              child: ElevatedButton(
                child: const Text('강사'),
                onPressed: () {
                  appState.whatuser = false; // 앱의 상태를 관리합니다. 현재 사용자가 강사인지 복지사인지를 구분합니다.
                  Navigator.push( // 버튼을 클릭하면 새로운 화면으로 이동합니다.
                    context,
                    MaterialPageRoute(builder: (context) => TeacherApp()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: 100.0,
              height: 50.0,
              child: ElevatedButton(
                child: const Text('복지사'),
                onPressed: () {
                  appState.whatuser = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InstitutionApp()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 84.0),
      ],
    );
  }
}

// 위젯 섹션 (가로 화면)
class StartPageLandscape extends StatelessWidget {
  const StartPageLandscape({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(width: 84.0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 24.0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 200.0,
                  height: 200.0,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        '노인복지시설에\n오신 것을\n환영합니다',
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        speed: const Duration(milliseconds: 250),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 100.0,
              height: 50.0,
              child: ElevatedButton(
                child: const Text('강사'),
                onPressed: () {
                  appState.whatuser = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherApp()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: 100.0,
              height: 50.0,
              child: ElevatedButton(
                child: const Text('복지사'),
                onPressed: () {
                  appState.whatuser = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InstitutionApp()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(width: 84.0),
      ],
    );
  }
}

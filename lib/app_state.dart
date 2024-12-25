import 'dart:async'; // 비동기 처리를 위한 패키지입니다.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore를 사용하기 위한 패키지입니다.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/drive/v3.dart'
    as drive; // Google Drive API를 사용하기 위한 패키지입니다.
import 'package:googleapis_auth/auth_io.dart'
    as auth; // Google API 인증을 위한 패키지입니다.
import 'package:welfare_attendance_project/googlecloud_config/configuration.dart';
import 'package:googleapis/sheets/v4.dart'
    as sheets; // Google Sheets API를 사용하기 위한 패키지입니다.
import 'package:http/http.dart' as http; // HTTP 요청을 위한 패키지입니다.
import 'package:path_provider/path_provider.dart'; // 로컬 경로를 가져오기 위한 패키지입니다.
import 'package:csv/csv.dart'; // CSV 파일을 다루기 위한 패키지입니다.
import 'dart:io'; // 파일 입출력을 위한 패키지입니다.

// 앱의 상태를 관리하고, 데이터를 업데이트하며 알림을 제공합니다.
// Flutter의 ChangeNotifier를 상속받아 상태 변화 시 UI에 알립니다.
class ApplicationState extends ChangeNotifier {
  late var _whatuser; // 복지사 로그인 시 true가 됩니다.

  List<String> _classlist = []; // 강사가 담당하는 수업 목록입니다.
  Map<String, dynamic>? _maplist = Map();

  Map<String, dynamic>? get maplist => _maplist;

  List<String> get classlist => _classlist;

  get whatuser => _whatuser;

  set whatuser(value) {
    _whatuser = value;
  }

  // 수업 목록의 변화를 감지하고 업데이트하는 함수입니다.
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      classlist_listener() {
    var listen = FirebaseFirestore.instance
        .collection('manager')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots() // 문서의 실시간 업데이트를 구독합니다.
        .listen((snapshot) {
      // Firestore에서 데이터를 가져와서 처리합니다.
      _classlist = snapshot.data()!.keys.toList();
      _classlist.remove('복지사');
      _maplist = snapshot.data();
      _maplist!.remove('복지사');
      List<String> keylist = [];

      if (_maplist != null)
        _maplist?.forEach((key, value) {
          if (value.first ==
              true) // 다른 담당자가 이미 등록한 수업이라면, 해당 수업의 키를 keylist에 추가합니다.
            keylist.add(key);
        });

      for (var key in keylist)
        _maplist?.remove(key); // 이미 담당자가 있는 수업을 _maplist에서 제거합니다.

      notifyListeners(); // 데이터 변경을 UI에 알립니다.
    });

    return listen;
  }

  var _attendancedata = null; // 출석 데이터를 저장할 변수입니다.

  get attendancedata => _attendancedata;
  List<String> _datelist = []; // 출석 날짜를 저장할 리스트입니다.

  List<String> get datelist => _datelist;

  // Google 스프레드시트를 CSV로 다운로드하고 데이터를 처리하는 함수입니다.
  void downloadcsv(String _spreadsheetId) async {
    final httpClient = http.Client(); // HTTP 요청을 위한 클라이언트를 생성합니다.

    // Google API 인증 정보를 로드 및 인증합니다.
    final credentials = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(SheetConfiguration.credentials),
        [drive.DriveApi.driveScope], // Google Drive API 사용 권한을 요청합니다.
        baseClient: httpClient);

    final driveApi = drive.DriveApi(credentials); // Drive API 인스턴스를 생성합니다.

    // Google 스프레드 시트를 CSV 형식으로 가져옵니다.
    final exportMimeType = 'text/csv'; // 파일 형식을 CSV로 설정합니다.
    final response = await driveApi.files.export(_spreadsheetId, exportMimeType,
        downloadOptions: drive.DownloadOptions.fullMedia); // 전체 파일을 다운로드합니다.

    List<int> dataStore = []; // 파일 데이터를 저장할 리스트입니다.

    // 다운로드 스트림에서 데이터를 읽고 처리합니다.
    var listener = response!.stream.listen((data) {
      dataStore.insertAll(dataStore.length, data); // 데이터를 dataStore에 저장합니다.
    }, onDone: () async {
      // 다운로드 완료 시 작업을 수행합니다.
      Directory tempDir = await getTemporaryDirectory(); // 임시 디렉토리의 경로를 가져옵니다.
      String tempPath = tempDir.path; // 임시 디렉토리의 경로를 저장합니다.
      File file = File('$tempPath/test'); // 임시 파일을 생성합니다.
      await file.writeAsBytes(dataStore); // 데이터를 파일로 저장합니다.
      String content = file.readAsStringSync(); // 파일 내용을 문자열로 읽습니다.
      _attendancedata =
          const CsvToListConverter().convert(content); // CSV를 리스트로 변환합니다.
      _datelist = [];

      if (_attendancedata != null && _attendancedata.isNotEmpty) {
        // CSV 첫 번째 행에서 날짜 데이터를 추출합니다.
        for (var date in _attendancedata[0]) {
          if (date != '이름' && date != '전화번호') {
            _datelist.add(date);
          }
        }
      }
      notifyListeners(); // 데이터 변경을 알립니다.
    }, onError: (error) {
      print('Error: $error'); // 에러 로그를 출력합니다.
    });
  }
}

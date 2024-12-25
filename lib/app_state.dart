import 'dart:async'; // 비동기 처리를 위한 패키지입니다.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore를 사용하기 위한 패키지입니다.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive; // Google Drive API를 사용하기 위한 패키지입니다.
import 'package:googleapis_auth/auth_io.dart' as auth; // Google API 인증을 위한 패키지입니다.
import 'package:welfare_attendance_project/googlecloud_config/configuration.dart';
import 'package:googleapis/sheets/v4.dart' as sheets; // Google Sheets API를 사용하기 위한 패키지입니다.
import 'package:http/http.dart' as http; // HTTP 요청을 위한 패키지입니다.
import 'package:path_provider/path_provider.dart'; // 로컬 경로를 가져오기 위한 패키지입니다.
import 'package:csv/csv.dart'; // CSV 파일을 다루기 위한 패키지입니다.
import 'dart:io'; // 파일 입출력을 위한 패키지입니다.

// 앱의 상태를 관리하고, 데이터를 업데이트하며 알림을 제공합니다.
// Flutter의 ChangeNotifier를 상속받아 상태 변화 시 UI에 알립니다.
class ApplicationState extends ChangeNotifier {
  late var _whatuser; // 복지사 로그인 시 true가 됩니다.

  List<String> _classlist = []; // 강사가 담당하는 수업 목록입니다.
  Map<String, dynamic>? _maplist = Map(); // contain bool to check if other teacher take class and excelid

  Map<String, dynamic>? get maplist => _maplist;

  List<String> get classlist => _classlist;

  get whatuser => _whatuser;

  set whatuser(value) {
    _whatuser = value;
  }

  // 수업 목록의 변화를 감지하고 업데이트하는 함수입니다.
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> classlist_listener() {
    var listen = FirebaseFirestore.instance
        .collection('manager')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots() // 문서의 실시간 업데이트를 구독합니다.
        .listen((snapshot) { // Firestore에서 데이터를 가져와서 처리합니다.
      _classlist = snapshot.data()!.keys.toList();
      _classlist.remove('복지사');
      _maplist = snapshot.data();
      _maplist!.remove('복지사');
      List<String> keylist = [];

      if (_maplist != null)
        _maplist?.forEach((key, value) {
          if (value.first == true) // 다른 담당자가 이미 등록한 수업이라면, 해당 수업의 키를 keylist에 추가합니다.
            keylist.add(key);
        });

      for (var key in keylist) _maplist?.remove(key); // 이미 담당자가 있는 수업을 _maplist에서 제거합니다.

      notifyListeners(); // 데이터 변경을 UI에 알립니다.
    });

    return listen;
  }

  var _attendancedata = null;

  get attendancedata => _attendancedata;
  List<String> _datelist = [];

  List<String> get datelist => _datelist;

  void downloadcsv(String _spreadsheetId) async {
    final httpClient = http.Client();
    // Load the client secrets JSON file obtained from GCP
    final credentials = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(SheetConfiguration.credentials),
        [drive.DriveApi.driveScope],
        baseClient: httpClient);
    // Create an instance of the Drive API
    final driveApi = drive.DriveApi(credentials);
    // Export the Sheets file as CSV
    final exportMimeType = 'text/csv';
    final response = await driveApi.files.export(
        _spreadsheetId, exportMimeType,
        downloadOptions: drive.DownloadOptions.fullMedia);
    // stream(response);
    List<int> dataStore = [];

    var listener = response!.stream.listen((data) {
      print(dataStore);
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () async {
      Directory tempDir =
      await getTemporaryDirectory(); //Get temp folder using Path Provider
      String tempPath = tempDir.path; //Get path to that location
      File file = File('$tempPath/test'); //Create a dummy file
      await file.writeAsBytes(
          dataStore); //Write to that file from the datastore you created from the Media stream
      String content = file.readAsStringSync(); // Read String from the file
      _attendancedata = const CsvToListConverter().convert(content);
      print(_attendancedata); //Finally you have your text
      print("Task Done");
      _datelist = [];

      if (_attendancedata != null && _attendancedata.isNotEmpty) {
        for (var date in _attendancedata[0]) {
          if (date != '이름' && date != '전화번호') {
            _datelist.add(date);
          }
        }
      }
      notifyListeners();
    }, onError: (error) {
      print("Some Error");
    });
  }
}

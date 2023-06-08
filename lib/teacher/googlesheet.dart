// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:welfare_attendance_project/googlecloud_config/configuration.dart';
// import 'package:googleapis/sheets/v4.dart' as sheets;
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:http/http.dart' as http;
// import 'package:gsheets/gsheets.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:csv/csv.dart';
// import 'dart:convert';
// import 'dart:io';
// class sheetclass {
//   final String _spreadsheetId = '1cZ5q-QsL-XET1W-VaTbsyCdD1ZdWgzh4MuxnhZRGtYs';
//   // late String _spreadsheetId;
//   final String _workSheetTitle = 'sheet';
//   late var _data;
//
//   get data => _data;
//   Spreadsheet? spreadsheet = null;
//   Worksheet? workSheet = null;
//
//   sheetclass(){
//     find_sheetid();
//     downloadcsv();
//   }
//   void sheetgoogle() async {
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     // final googleSignIn = GoogleSignIn(
//     //   scopes: <String>[
//     //     'https://www.googleapis.com/auth/spreadsheets',
//     //   ],
//     // );
//     // // Authenticate the user
//     // final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//     // Obtain the authentication token
//     final GoogleSignInAuthentication googleAuth =
//     await googleUser!.authentication;
//     final accessToken = googleAuth.accessToken;
//     Map<String, dynamic> json = jsonDecode(accessToken!);
//     print('json1: $json');
//     // final gsheets = GSheets(json);
//
//     // // Set up the Google Sheets API client and authenticate with the access token
//     final httpClient = http.Client();
//     final authClient = authenticatedClient(
//       httpClient,
//       AccessCredentials(
//         AccessToken(
//             'Bearer', accessToken!, DateTime.now().add(Duration(hours: 1))),
//         'user-agent',
//         ['https://www.googleapis.com/auth/spreadsheets'],
//       ),
//     );
//
//     final sheetsApi = sheets.SheetsApi(authClient);
//
//     // spreadsheet ??= await gsheets.spreadsheet(_spreadsheetId);
//     //
//     // if (workSheet == null) {
//     //   workSheet = await spreadsheet.worksheetByTitle(_workSheetTitle)!;
//     //   workSheet ??= await spreadsheet.addWorksheet(_workSheetTitle);
//     // }
//   }
//
//   void find_sheetid() async {
//     // Load the client secrets JSON file obtained from GCP
//     final credentials = await auth.clientViaServiceAccount(
//       auth.ServiceAccountCredentials.fromJson(SheetConfiguration.credentials),
//       [drive.DriveApi.driveReadonlyScope],
//     );
//     // Create an instance of the Drive API
//     final driveApi = drive.DriveApi(credentials);
//
//     // Define the spreadsheet file name
//     final fileName = '한글교실';
//
//     try {
//       // Search for the spreadsheet file by name
//       final files = await driveApi.files.list(q: "name='$fileName'");
//
//       if (files.files != null && files.files!.isNotEmpty) {
//         final _spreadsheetId =  files.files!.first.id!;
//         // final dirveid = files.files!.first.resourceKey;
//         // downloadcsv();
//         print('Spreadsheet ID: $_spreadsheetId');
//         // print('drive ID: $dirveid');
//       } else {
//         print('No spreadsheet found with the specified file name');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   Future<void> initalWorkSheet() async {
//     final gsheets = SheetConfiguration.sheet;
//     spreadsheet ??= await gsheets.spreadsheet(_spreadsheetId);
//     // final service = GSheetService('path/to/credentials.json');
//     if (workSheet == null) {
//       print('spreadsheet :$spreadsheet');
//       workSheet = await spreadsheet!.worksheetByTitle(_workSheetTitle)!;
//       workSheet ??= await spreadsheet!.addWorksheet(_workSheetTitle);
//     }
//   }
//
//   void insertRow({
//     List<dynamic>? row,
//   }) async {
//     if (workSheet == null) {
//       print('Worksheet is null.');
//       return;
//     }
//
//     final result = await workSheet!.values.insertRow(
//       2,
//       [
//         4030.22,
//         'Bora Test2',
//         20,
//         {'dd': 'ss'}.toString()
//       ],
//     );
//     print('$_workSheetTitle insertRow completed $result');
//   }
//
//   void downloadcsv() async {
//
//     final httpClient = http.Client();
//     // Load the client secrets JSON file obtained from GCP
//     final credentials = await auth.clientViaServiceAccount(
//         auth.ServiceAccountCredentials.fromJson(SheetConfiguration.credentials),
//         [drive.DriveApi.driveScope],baseClient: httpClient
//     );
//     // Create an instance of the Drive API
//     final driveApi = drive.DriveApi(credentials);
//     final sheetsApi = sheets.SheetsApi(credentials);
//     // Export the Sheets file as CSV
//     final exportResponse = await sheetsApi.spreadsheets.get(_spreadsheetId, $fields: 'sheets.properties.sheetId');
//     final sheetId = exportResponse.sheets?.first?.properties?.sheetId;
// //     final filess = await driveApi.files.get(_spreadsheetId,downloadOptions:drive.DownloadOptions.fullMedia);
// //     final exportUrl = 'https://docs.google.com/spreadsheets/export?id=$_spreadsheetId&exportFormat=csv';
//     final exportUrl = 'https://docs.google.com/spreadsheets/export?id=$_spreadsheetId&exportFormat=csv&gid=$sheetId';
//     // Send a GET request to the export URL to download the file content
//     final response = await httpClient.get(Uri.parse(exportUrl));
//     final exportMimeType = 'text/csv';
//     final responses = await driveApi.files.export(_spreadsheetId, exportMimeType, downloadOptions: drive.DownloadOptions.fullMedia);
//     stream(responses);
//     // print('file :  ${file.toString()}');
//
// // Save the file to local storage
//     final csvContent = response.body;
//
//     final documentsDir = await getTemporaryDirectory(); //Get temp folder using Path Provider
//     final filepath = documentsDir.path + 'aaa.csv';
//     // print(file.name);
//     // final filePath = path.basename(file.name);
//     // final filePath = 'path_to_downloaded_file.csv';
//     final file = File(filepath);
//     await file.writeAsString(csvContent);
//     // await file.writeAsBytes(response.bodyBytes); //file에다가 response write함 (결국 html 내용 write 한다는뜻)
//
//     print('File downloaded and saved to: $filepath');
//     // Read the content of the downloaded file
//     final fileContent = await file.readAsStringSync();
//     List data = const CsvToListConverter().convert(fileContent);
//     // print('File content:\n$data');
//
//   }
//
//   void stream(var response){
//     List<int> dataStore = [];
//     response.stream.listen((data) {
//       print(dataStore);
//       dataStore.insertAll(dataStore.length, data);
//     }, onDone: () async {
//       Directory tempDir = await getTemporaryDirectory(); //Get temp folder using Path Provider
//       String tempPath = tempDir.path;   //Get path to that location
//       File file = File('$tempPath/test'); //Create a dummy file
//       await file.writeAsBytes(dataStore); //Write to that file from the datastore you created from the Media stream
//       String content = file.readAsStringSync(); // Read String from the file
//       _data = const CsvToListConverter().convert(content);
//
//       print(data); //Finally you have your text
//       print("Task Done");
//
//     }, onError: (error) {
//       print("Some Error");
//     });
//   }
// // Future<void> readCSVData() async {
// //   final service = GSheetService('path/to/credentials.json');
// //   await service.init();
// //
// //   final spreadsheetId = 'YOUR_SPREADSHEET_ID';
// //   final worksheetTitle = 'YOUR_WORKSHEET_TITLE';
// //
// //   final response = await service.getSheet(
// //     spreadsheetId: spreadsheetId,
// //     worksheetTitle: worksheetTitle,
// //   );
// //
// //   if (response.status == HttpStatus.ok) {
// //     final sheetData = response.data!;
// //     for (final row in sheetData) {
// //       final rowData = row['rowData'];
// //       if (rowData != null) {
// //         for (final cell in rowData) {
// //           final value = cell['formattedValue'];
// //           print(value);
// //         }
// //       }
// //     }
// //   } else {
// //     print('Failed to fetch sheet data. Status code: ${response.status}');
// //   }
// // }
// }
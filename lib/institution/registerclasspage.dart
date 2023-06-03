import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:welfare_attendance_project/app_state.dart';
import 'package:welfare_attendance_project/googlecloud_config/configuration.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class RegisterClassPage extends StatefulWidget {
  RegisterClassPage({Key? key}) : super(key: key);

  @override
  State<RegisterClassPage> createState() => _RegisterClassPageState();
}

class _RegisterClassPageState extends State<RegisterClassPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  Stream<DocumentSnapshot<Map<String, dynamic>>> _excelnameStream =
      FirebaseFirestore.instance
          .collection('manager')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();

  bool showspiner = false;
  List classlist = <String>[];

  Future<String> find_sheetid() async {
    // Load the client secrets JSON file obtained from GCP
    final credentials = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(SheetConfiguration.credentials),
      [drive.DriveApi.driveReadonlyScope],
    );
    // Create an instance of the Drive API
    final driveApi = drive.DriveApi(credentials);

    // Define the spreadsheet file name
    final fileName = _nameController.text.trim();

    try {
      // Search for the spreadsheet file by name
      final files = await driveApi.files.list(q: "name='$fileName'");

      if (files.files != null && files.files!.isNotEmpty) {
        final _spreadsheetId = files.files!.first.id!;
        // final dirveid = files.files!.first.resourceKey;
        // downloadcsv();
        print('Spreadsheet ID: $_spreadsheetId');
        // print('drive ID: $dirveid');
        return _spreadsheetId;
      } else {
        print('No spreadsheet found with the specified file name');
        return "";
      }
    } catch (e) {
      print('Error: $e');
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    classlist = appState.classlist;
    return Scaffold(
      appBar: AppBar(
        title: Text('강의등록'),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showspiner,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '꼭 순서대로 따라해주세요!\n1.먼저 구글드라이브에서 출석을 관리하고 싶은 강의의 엑셀파일을 만든다\n 2.만든 엑셀 파일에아래의 이메일주소를 편집자로 공유한다\nattendancesheet@welfare-attendance-388218.iam.gserviceaccount.com  \n 3.엑셀파일과 같은 이름을 아래에 입력한다'),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이름을 입력해주세요';
                            }
                            return null;
                          },
                          controller: _nameController,
                          decoration: const InputDecoration(
                            filled: true,
                            labelText: '강의 이름',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    FilledButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              showspiner = true;
                            });
                            final sheetid = await find_sheetid();
                            setState(() {
                              showspiner = false;
                            });
                            if (sheetid == "")
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('생성한 엑셀 파일 이름을 정확히 입력해주세요')));
                            else {
                              await FirebaseFirestore.instance
                                  .collection('manager')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update(<String, dynamic>{
                                _nameController.text.trim(): [false, sheetid],
                              });
                              // await FirebaseFirestore.instance
                              //     .collection('manager')
                              //     .doc(FirebaseAuth.instance.currentUser!.uid)
                              //     .collection('teacher')
                              // .doc(FirebaseAuth.instance.currentUser!.uid)
                              // .update(<String,dynamic>{
                              //   _nameController.text.trim() : false
                              // });
                            }
                          }
                        },
                        child: Text('등록'))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text('강의 리스트'),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: classlist.length,
                    itemBuilder: (context, index) {
                      var value = classlist[index];

                      return ListTile(
                        leading: Text(value),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('manager')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update(<String, dynamic>{
                              value: FieldValue.delete()
                            });

                            // print(
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

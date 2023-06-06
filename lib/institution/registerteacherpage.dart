import 'package:flutter/material.dart';
import 'package:welfare_attendance_project/app_state.dart';
import 'package:welfare_attendance_project/institution/qrscanner.dart';
import 'calender.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class RegisterTeacherPage extends StatefulWidget {
  RegisterTeacherPage({Key? key}) : super(key: key);

  @override
  State<RegisterTeacherPage> createState() => _RegisterTeacherPageState();
}

class _RegisterTeacherPageState extends State<RegisterTeacherPage> {
  Map<String, dynamic> _maplist = Map();

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  var _calenderController = TextEditingController();

  final _phonenumberController = TextEditingController();

  String dropdownValue = '';
  String qrcode = '';

  void get_qrcode(String? code) {
    setState(() {
      this.qrcode = code!;
    });
  }

  void select_canlender(String calendar) {
    setState(() {
      this._calenderController = TextEditingController(text: calendar);
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    _maplist = appState.maplist!;
    if (dropdownValue == '')
      dropdownValue = _maplist.keys.length == 0 ? '' : _maplist.keys.first;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '강사등록',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12.0),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 100.0,
                            // height: 50.0,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (_maplist.keys.length == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                '새로운 강사에게 할당 가능한 강의가 없습니다')));
                                    return;
                                  }
                                  if (qrcode == '') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                '등록할 강사의 QR 코드를 인증해 주세요')));
                                    return;
                                  }

                                  if (_formKey.currentState!.validate()) {
                                    late var check;
                                    await FirebaseFirestore.instance
                                        .collection('teachers')
                                        .where('teacheruid', isEqualTo: qrcode)
                                        .get()
                                        .then((value) {
                                      check = value.docs.length;
                                    });
                                    // print('null : ${nullcheck}');
                                    if (check > 0) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text('이미 등록된 강사입니다')));
                                      return;
                                    }
                                    late final sheetid;
                                    _maplist.forEach((key, value) {
                                      if (key == dropdownValue)
                                        sheetid = value[1];
                                    });
                                    await FirebaseFirestore.instance
                                        .collection('manager')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .update(<String, dynamic>{
                                      dropdownValue: [true, sheetid],
                                    });

                                    await FirebaseFirestore.instance
                                        .collection('manager')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .collection('teacher')
                                        .doc(qrcode)
                                        .set(<String, dynamic>{
                                      'teacheruid': qrcode,
                                      'name': _nameController.text.trim(),
                                      'birthday':
                                          _calenderController.text.trim(),
                                      'phonenumber':
                                          _phonenumberController.text.trim(),
                                      dropdownValue: sheetid
                                    });

                                    await FirebaseFirestore.instance
                                        .collection('teachers')
                                        .doc(qrcode)
                                      ..set(<String, dynamic>{
                                        'teacheruid': qrcode,
                                        dropdownValue: sheetid
                                      });
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('등록')),
                          ),
                          // SizedBox(
                          //   width: 20,
                          // ),
                          SizedBox(
                            width: 100.0,
                            // height: 50.0,
                            child: FilledButton(
                              child: const Text('초기화'),
                              onPressed: () {
                                _nameController.clear();
                                _phonenumberController.clear();
                                _calenderController.clear();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름을 입력해주세요';
                          }
                          return null;
                        },
                        controller: _nameController,
                        decoration: const InputDecoration(
                          // filled: true,
                          labelText: '이름',
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '생년월일을 선택해주세요';
                                }
                                return null;
                              },
                              controller: _calenderController,
                              decoration: const InputDecoration(
                                // filled: true,
                                labelText: '생년월일',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Calender(
                            selectedcalender: select_canlender,
                          )
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '전화번호를 입력해주세요';
                          }
                          RegExp numberRegex = RegExp(r'^[0-9]+$');
                          if (!numberRegex.hasMatch(value!)) {
                            return '숫자만 입력해주세요';
                          }
                          return null;
                        },
                        controller: _phonenumberController,
                        decoration: const InputDecoration(
                          // filled: true,
                          labelText: '전화번호',
                        ),
                      ),

                      const SizedBox(height: 12.0),
                      _maplist.keys.length > 0
                          ? DropdownButton<String>(
                              value: dropdownValue,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple),
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  dropdownValue = value!;
                                });
                              },
                              items: _maplist.keys
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )
                          : const Text('모든 강의가 할당됐거나 등록된 강의가 없습니다'),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          qrcode == ''
                              ? const Expanded(
                                  child: Text('강사의 QR 코드를 인증해 주세요'))
                              : const Expanded(child: Text('인증되었습니다')),
                          const SizedBox(width: 12.0),
                          SizedBox(
                            width: 120.0,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QRScanner(
                                            getQrcode: get_qrcode,
                                          )),
                                );
                              },
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.qr_code_2),
                                    SizedBox(width: 4.0),
                                    Text('인증'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

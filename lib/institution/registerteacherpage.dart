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

  final _classController = TextEditingController();
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
        title: Text('강사등록'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름을 입력해주세요';
                          }
                          return null;
                        },
                        controller: _nameController,
                        decoration: const InputDecoration(
                          filled: true,
                          labelText: '이름',
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '날짜를 선택해주세요';
                                }
                                return null;
                              },
                              controller: _calenderController,
                              decoration: const InputDecoration(
                                filled: true,
                                labelText: '날짜',
                              ),
                            ),
                          ),
                          Calender(
                            selectedcalender: select_canlender,
                          )
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '숫자를 입력해주세요';
                          }
                          RegExp numberRegex = RegExp(r'^[0-9]+$');
                          if (!numberRegex.hasMatch(value!))
                            return '숫자만 입력해주세요';
                          return null;
                        },
                        controller: _phonenumberController,
                        decoration: const InputDecoration(
                          filled: true,
                          labelText: '전화번호',
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '강의를 선택해주세요';
                          }
                          return null;
                        },
                        controller: _classController,
                        decoration: const InputDecoration(
                          filled: true,
                          labelText: '강의',
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
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
                          : Text('모든 강의가 할당됬거나 등록된 강의가 없습니다'),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          qrcode == ''
                              ? Expanded(child: Text('강사의 qrcode를 인증해 주세요'))
                              : Expanded(child: Text('인증되었습니다')),
                          SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QRScanner(
                                            getQrcode: get_qrcode,
                                          )),
                                );
                              },
                              child: Text('qrscan')),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                if (qrcode == '') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('등록할 강사의 QRcode를 인증해주세요')));
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
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
                                      .add(<String, dynamic>{
                                    'teacheruid': qrcode,
                                    'name': _nameController.text.trim(),
                                    'birthday': _calenderController.text.trim(),
                                    'phonenumber':
                                        _phonenumberController.text.trim(),
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
                              child: Text('등록')),
                          SizedBox(
                            width: 20,
                          ),
                          FilledButton(
                            child: const Text('Clear'),
                            onPressed: () {
                              _nameController.clear();
                              _phonenumberController.clear();
                              _classController.clear();
                            },
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

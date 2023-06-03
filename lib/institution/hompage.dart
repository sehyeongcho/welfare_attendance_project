import 'dart:async';

import 'package:flutter/material.dart';
import 'package:welfare_attendance_project/app_state.dart';
import 'package:welfare_attendance_project/institution/registerclasspage.dart';
import 'package:welfare_attendance_project/institution/registerteacherpage.dart';

import 'package:provider/provider.dart';
import '../profilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late var appState;
  final Stream<QuerySnapshot> _teacherstream = FirebaseFirestore.instance
      .collection('manager')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('teacher')
      .snapshots();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      classlist_listener = null;

  @override
  void dispose() {
    if (classlist_listener != null) classlist_listener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<ApplicationState>();
    if (classlist_listener == null)
      classlist_listener = appState.classlist_listener();
    return Scaffold(
      appBar: AppBar(
        title: Text('강사목록'),
        leading: IconButton(
          icon: const Icon(
            Icons.person,
            semanticLabel: 'profile',
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    late var check;
                    await FirebaseFirestore.instance
                        .collection('manager')
                        .where('복지사',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .get()
                        .then((value) {
                      check = value.docs.length;
                    });
                    // print('null : ${nullcheck}');
                    if (check == 0)
                      await FirebaseFirestore.instance
                          .collection('manager')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .set(<String, dynamic>{
                        '복지사': FirebaseAuth.instance.currentUser!.uid
                      });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterClassPage()),
                    );
                  },
                  child: Text('강의등록')),
              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    late var check;
                    await FirebaseFirestore.instance
                        .collection('manager')
                        .where('복지사',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .get()
                        .then((value) {
                      check = value.docs.length;
                    });
                    // print('null : ${nullcheck}');
                    if (check == 0)
                      await FirebaseFirestore.instance
                          .collection('manager')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .set(<String, dynamic>{
                        '복지사': FirebaseAuth.instance.currentUser!.uid
                      });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterTeacherPage()),
                    );
                  },
                  child: Text('강사등록')),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _teacherstream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data!.size == 0)
                return Center(
                  child: Text('There is no item!'),
                );
              print('here');
              return Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16.0),
                  childAspectRatio: 8.0 / 9.0,
                  children: snapshot.data!.docs
                      .map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8.0, 12.0, 8.0, 0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        data['name'],
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(data['phonenumber']),
                                      Text(data['birthday'])
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList()
                      .cast(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

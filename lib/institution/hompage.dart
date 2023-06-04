import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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

  store_userinfo() async {
    late var check;
    await FirebaseFirestore.instance
        .collection('manager')
        .where('복지사', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      check = value.docs.length;
    });
    // print('null : ${check}');
    if (check == 0)
      await FirebaseFirestore.instance
          .collection('manager')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(
              <String, dynamic>{'복지사': FirebaseAuth.instance.currentUser!.uid});
    classlist_listener = appState.classlist_listener();
  }

  @override
  void dispose() {
    if (classlist_listener != null) classlist_listener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<ApplicationState>();
    if (classlist_listener == null) {
      store_userinfo();
      // classlist_listener = appState.classlist_listener();
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('강사목록'),
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
              const SizedBox(width: 24.0),
              ElevatedButton(
                  onPressed: () async {
                    // late var check;
                    // await FirebaseFirestore.instance
                    //     .collection('manager')
                    //     .where('복지사',
                    //         isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    //     .get()
                    //     .then((value) {
                    //   check = value.docs.length;
                    // });
                    // // print('null : ${nullcheck}');
                    // if (check == 0)
                    //   await FirebaseFirestore.instance
                    //       .collection('manager')
                    //       .doc(FirebaseAuth.instance.currentUser!.uid)
                    //       .set(<String, dynamic>{
                    //     '복지사': FirebaseAuth.instance.currentUser!.uid
                    //   });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterClassPage()),
                    );
                  },
                  child: const Text('강의등록')),
              const SizedBox(width: 24.0),
              ElevatedButton(
                  onPressed: () async {
                    // late var check;
                    // await FirebaseFirestore.instance
                    //     .collection('manager')
                    //     .where('복지사',
                    //         isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    //     .get()
                    //     .then((value) {
                    //   check = value.docs.length;
                    // });
                    // // print('null : ${nullcheck}');
                    // if (check == 0)
                    //   await FirebaseFirestore.instance
                    //       .collection('manager')
                    //       .doc(FirebaseAuth.instance.currentUser!.uid)
                    //       .set(<String, dynamic>{
                    //     '복지사': FirebaseAuth.instance.currentUser!.uid
                    //   });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterTeacherPage()),
                    );
                  },
                  child: const Text('강사등록')),
              const SizedBox(width: 24.0),
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
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data!.size == 0) {
                return const Center(
                  child: Text('등록된 강사가 없습니다'),
                );
              }
              // print('here');
              return Expanded(
                child: GridView.count(
                  crossAxisCount: 1,
                  padding: const EdgeInsets.all(16.0),
                  childAspectRatio: 5.0 / 2.0,
                  children: snapshot.data!.docs
                      .map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AspectRatio(
                                aspectRatio: 1 / 1,
                                child: Lottie.network(
                                  'https://assets2.lottiefiles.com/packages/lf20_h9rxcjpi.json',
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 8.0),
                                            Text(
                                              data['phonenumber'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            Text(
                                              data['birthday'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        TextButton(
                                          child: const Text('more'),
                                          onPressed: () {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         DetailScreen(product: product),
                                            //   ),
                                            // );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                    ),
                                  ],
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:welfare_attendance_project/profilepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:welfare_attendance_project/teacher/classdate.dart';
import '../app_state.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late var sheetid;
  late var classname;

  final Stream<DocumentSnapshot<Map<String, dynamic>>> _classstream =
      FirebaseFirestore.instance
          .collection('teachers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '강의목록',
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _classstream,
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.data!.exists)
                  return Center(
                    child: Text('등록된 강의가 없습니다'),
                  );

                Map<String, dynamic> data =
                    snapshot.data!.data()! as Map<String, dynamic>;

                data.remove('teacheruid');
                data.forEach((key, value) {
                  sheetid = value;
                  classname = key;
                });
                var classlist = data.keys.toList();
                return Expanded(
                  child: GridView.count(
                    crossAxisCount: 1,
                    padding: const EdgeInsets.all(16.0),
                    childAspectRatio: 5.0 / 2.0,
                    children: classlist
                        .map((element) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ClassDate(
                                          classname: classname,
                                          sheetid: sheetid,
                                        )),
                              );
                            },
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  AspectRatio(
                                    aspectRatio: 1 / 1,
                                    child: Lottie.network(
                                      'https://assets3.lottiefiles.com/packages/lf20_yjrdpceb.json',
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8.0, 12.0, 8.0, 0.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                element,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
      ),
    );
  }

  // List<Widget> cardtolist(ThemeData theme) {
  //   late Card card;
  //   List<Widget> list = [];
  //   List<bool> _selectedIcon = [];
  //   for (var data in sheet.data) {
  //     if (data[0] != '이름') {
  //       if (data[2] == 'o')
  //         _selectedIcon = [true, false];
  //       else
  //         _selectedIcon = [false, true];
  //       list.add(Card(
  //         child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       '${data[0]}',
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4.0),
  //                     Text('${data[1]}'),
  //                   ],
  //                 ),
  //                 // SizedBox(width: 20,),
  //                 ToggleButtons(
  //                   direction: Axis.horizontal,
  //                   onPressed: (int index) {
  //                     setState(() {
  //                       // The button that is tapped is set to true, and the others to false.
  //                       for (int i = 0; i < _selectedIcon.length; i++) {
  //                         // if(data[2] == 'o')
  //                         //  index = index!;
  //                         _selectedIcon[i] = i == index;
  //                       }
  //                       _grid_or_list = index;
  //                     });
  //                   },
  //                   borderRadius: const BorderRadius.all(Radius.circular(8)),
  //                   selectedBorderColor: theme.colorScheme.primary,
  //                   selectedColor: theme.colorScheme.primary,
  //                   fillColor: Colors.blue[200],
  //                   color: Colors.grey,
  //                   isSelected: _selectedIcon,
  //                   children: icons,
  //                 ),
  //                 // Text('${data[2]}')
  //               ],
  //             )),
  //       ));
  //     }
  //   }
  //   return list;
  // }
}

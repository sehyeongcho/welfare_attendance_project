import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editteacherpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class DetailPage extends StatefulWidget {
  DetailPage({Key? key, required this.teacheruid}) : super(key: key) {
    teacherstream = FirebaseFirestore.instance
        .collection('manager')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('teacher')
        .doc(teacheruid)
        .snapshots();
  }

  late Stream<DocumentSnapshot<Map<String, dynamic>>> teacherstream;

  final teacheruid;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String convertTime(dynamic time) {
    final timestamp = time;
    final date = DateTime.fromMillisecondsSinceEpoch(
      timestamp.seconds * 1000 + (timestamp.nanoseconds / 1000000).round(),
    );

    return date.toString();
  }

  late var name;
  late var classname;
  late var phonenumber;
  late var birthday;
  late var sheetid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '강사정보',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: <Widget>[
          // When you click the pencil icon(Icons.create), you can modify(update) the information of the item
          IconButton(
            icon: const Icon(
              Icons.create,
              semanticLabel: 'edit',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditTeacherPage(
                          name: name,
                          phonenum: phonenumber,
                          classname: classname,
                          birthday: birthday,
                          sheetid: sheetid,
                          teacheruid: widget.teacheruid,
                        )),
              );
            },
          ),

          // When you click the trash icon(Icons.delete), you can delete the item
          IconButton(
            icon: const Icon(
              Icons.delete,
              semanticLabel: 'delete',
            ),
            onPressed: () async {
              // If the UID is different from yours (if you are not the author of the post), it should not be Modified or Deleted (you can use Firestore Document Fields or Security Rules)
              // if (FirebaseAuth.instance.currentUser!.uid ==
              //     widget.data['uid']) {
              //   showDialog<String>(
              //     context: context,
              //     builder: (BuildContext context) => AlertDialog(
              //       title: const Text('Delete'),
              //       content: const Text('Are you sure you want to delete it?'),
              //       actions: <Widget>[
              //         TextButton(
              //           onPressed: () => Navigator.pop(context, 'Cancel'),
              //           child: const Text('Cancel'),
              //         ),
              //         TextButton(
              //           onPressed: () async {
              //             db
              //                 .collection("product")
              //                 .doc(widget.docId)
              //                 .delete()
              //                 .then(
              //                   (doc) => print("Document deleted"),
              //                   onError: (e) =>
              //                       print("Error updating document $e"),
              //                 );

              //             db.collection("user").get().then((querySnapshot) {
              //               for (var docSnapshot in querySnapshot.docs) {
              //                 docSnapshot.reference.update({
              //                   "wishlist":
              //                       FieldValue.arrayRemove([widget.docId]),
              //                 });
              //               }
              //             });

              //             await storageRef.child(widget.docId).delete();

              //             Navigator.pop(context, 'OK');
              //             Navigator.pop(context);
              //           },
              //           child: const Text('OK'),
              //         ),
              //       ],
              //     ),
              //   );
              // }

              FirebaseFirestore.instance
                  .collection('manager')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('teacher')
                  .doc(widget.teacheruid)
                  .delete();

              await FirebaseFirestore.instance
                  .collection('manager')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update(<String, dynamic>{
                classname: [false, sheetid],
              });

              FirebaseFirestore.instance
                  .collection('teachers')
                  .doc(widget.teacheruid)
                  .delete();
              Navigator.pop(context);
            },
          ),
        ],
      ),

      // Detail page should have Product Image, Name, Price and Description
      body: Column(
        children: [
          // Image
          Lottie.network(
            'https://assets2.lottiefiles.com/packages/lf20_h9rxcjpi.json',
            width: 300.0,
            height: 300.0,
          ),
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: widget.teacherstream,
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.data!.exists) {
                      return const Expanded(
                        child: Center(
                          child: Text('등록된 강사가 없습니다'),
                        ),
                      );
                    }
                    Map<String, dynamic> data =
                        snapshot.data!.data()! as Map<String, dynamic>;

                    data.forEach((key, value) {
                      if (key == 'name')
                        name = value;
                      else if (key == 'birthday')
                        birthday = value;
                      else if (key == 'phonenumber')
                        phonenumber = value;
                      else if (key != 'teacheruid') {
                        classname = key;
                        sheetid = value;
                      }
                    });

                    return Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.0),
                          // Price
                          Text(phonenumber.replaceAllMapped(
                              RegExp(r'(\d{3})(\d{3,4})(\d{4})'),
                              (m) => '${m[1]}-${m[2]}-${m[3]}')),
                          SizedBox(height: 12.0),
                          Text(birthday),
                          SizedBox(height: 12.0),
                          Divider(
                            thickness: 2.0,
                          ),
                          SizedBox(height: 12.0),

                          // Description
                          Text(classname),
                          SizedBox(height: 12.0),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

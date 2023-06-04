import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'editteacherpage.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key /*, required this.data, required this.docId*/})
      : super(key: key);

  // final Map<String, dynamic> data;
  // final String docId;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // @override
  // void initState() {
  //   super.initState();
  //   context.read<MyAppState>().initFavorite();
  // }

  String convertTime(dynamic time) {
    final timestamp = time;
    final date = DateTime.fromMillisecondsSinceEpoch(
      timestamp.seconds * 1000 + (timestamp.nanoseconds / 1000000).round(),
    );

    return date.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // create a Floating Action Button
      // before adding to wishlist: shopping_cart icon
      // after adding to wishlist: check icon
      // floatingActionButton: FloatingActionButton(
      //   child: Consumer<MyAppState>(
      //     builder: (context, appState, child) {
      //       return (appState.wishlistState['wishlist'] == null ||
      //               !appState.wishlistState['wishlist'].contains(widget.docId))
      //           ? const Icon(Icons.shopping_cart)
      //           : const Icon(Icons.check);
      //     },
      //   ),

      //   // when the floating action button is pressed, the item is added to wishlist
      //   onPressed: () {
      //     context.read<MyAppState>().toggleFavorite(widget.docId);
      //   },
      // ),
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
              // if (FirebaseAuth.instance.currentUser!.uid ==
              //     widget.data['uid']) {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         EditPage(data: widget.data, docId: widget.docId),
              //   ),
              //   );
              // }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditTeacherPage()),
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
            },
          ),
        ],
      ),

      // Detail page should have Product Image, Name, Price and Description
      body: ListView(
        children: [
          // Image
          Lottie.network(
            'https://assets2.lottiefiles.com/packages/lf20_h9rxcjpi.json',
            width: 300.0,
            height: 300.0,
          ),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      // Name
                      child: Text(
                        '강사 이름',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // StreamBuilder(
                    //   stream: db
                    //       .collection('product')
                    //       .doc(widget.docId)
                    //       .snapshots(),
                    //   builder: (context, snapshot) {
                    //     return FavoriteWidget(
                    //         data: widget.data, docId: widget.docId);
                    //   },
                    // ),
                  ],
                ),
                SizedBox(height: 12.0),

                // Price
                Text('강사 전화번호'),
                SizedBox(height: 12.0),
                Text('강사 생년월일'),
                SizedBox(height: 12.0),
                Divider(
                  thickness: 2.0,
                ),
                SizedBox(height: 12.0),

                // Description
                Text('강사 강의목록'),
                SizedBox(height: 12.0),

                // Show UID & creation time & recent update time (Use FieldValue.serverTimestamp())
                // Text("Creator: ${widget.data['uid']}"),
                // Text("${convertTime(widget.data['creationtime'])} Created"),
                // Text(
                //     "${convertTime(widget.data['recentupdatetime'])} Modified"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

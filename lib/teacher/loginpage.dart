import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // late var name;
  //
  // late var uid;
  // late var emailAddress;
  // var login_method = false;

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // void storeUserInfo() {
  //   final user = FirebaseAuth.instance.currentUser;
  //   // print('user : ${user}');
  //   if (user != null) {
  //     for (final providerProfile in user.providerData) {
  //       login_method = true;
  //       // ID of the provider (google.com, apple.com, etc.)
  //       final provider = providerProfile.providerId;
  //       print('provider : ${provider}');
  //       // UID specific to the provider
  //       uid = providerProfile.uid!;
  //       // Name, email address, and profile photo URL
  //       name = providerProfile.displayName;
  //       emailAddress = providerProfile.email;
  //     }
  //     if (login_method == false) {
  //       print(' Anonymous sign in');
  //       uid = user.uid;
  //       name = 'Jin Su Kim';
  //       emailAddress = 'Anonymous';
  //     }
  //   }
  //   if (login_method == true) {
  //     FirebaseFirestore.instance
  //         .collection('user')
  //         .doc(uid)
  //         .set(<String, dynamic>{
  //       'email': emailAddress,
  //       'name': name,
  //       'status_message': 'I promise to take the test honestly before GOD!',
  //       'uid': uid
  //     });
  //   } else {
  //     FirebaseFirestore.instance
  //         .collection('user')
  //         .doc(uid)
  //         .set(<String, dynamic>{
  //       'status_message': 'I promise to take the test honestly before GOD!',
  //       'uid': uid
  //     });
  //   }
  // }

  Future<void> signInAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("Signed in with temporary account.");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }
  }

  Future<void> storeFireBase() async {

    // print('null check : ${FirebaseAuth.instance.currentUser!.uid}');
    // await Future.delayed(Duration(seconds: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('manager')
        .where('복지사', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    int check = snapshot.docs.length;
    await Future.delayed(Duration(seconds: 1));
      print('here : $check');
    // if (check == 0) {
    //   await FirebaseFirestore.instance
    //       .collection('manager')
    //       .doc(FirebaseAuth.instance.currentUser!.uid)
    //       .set(
    //           <String, dynamic>{'복지사': FirebaseAuth.instance.currentUser!.uid});
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 60.0),
          children: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('첫 화면으로 돌아가기')),
            Text('강사 로그인'),
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/diamond.png'),
                const SizedBox(height: 16.0),
                const Text('SHRINE'),
              ],
            ),
            const SizedBox(height: 120.0),
            // TODO: Remove filled: true values (103)
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0)),
                padding: EdgeInsets.all(0.0),
              ),
              onPressed: () async{
                await signInWithGoogle();
                // try {
                //   await storeFireBase();
                // } catch (e) {
                //   print('Error storing data: $e');
                // }
                // storeUserInfo();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: 50,
                      width: 50,
                      margin: EdgeInsets.zero,
                      color: Colors.orange,
                      child: Icon(Icons.add)),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Google')
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0)),
                padding: EdgeInsets.all(0.0),
              ),
              onPressed: () async {
                await signInAnonymously();
                // storeUserInfo();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: 50,
                      width: 50,
                      margin: EdgeInsets.zero,
                      color: Colors.black,
                      child: Icon(Icons.question_mark)),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Guest')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

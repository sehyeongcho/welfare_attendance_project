import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '로그인',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: <Widget>[
            // TextButton(
            //   onPressed: () {
            //   Navigator.pop(context);
            // },
            // child: const Text('시작 화면으로 돌아가기'),
            // ),
            Center(
              child: Text(
                '강사님 환영합니다',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 24.0),
            Column(
              children: <Widget>[
                Lottie.network(
                  'https://assets2.lottiefiles.com/packages/lf20_h9rxcjpi.json',
                  width: 300,
                  height: 300,
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            // TODO: Remove filled: true values (103)
            Center(
              child: SizedBox(
                width: 256,
                height: 64,
                child: Material(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: signInWithGoogle,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // const SizedBox(width: 12.0),
                            Ink.image(
                              image: const AssetImage('assets/google_logo.png'),
                              height: 32,
                              width: 32,
                            ),
                            const SizedBox(width: 12.0),
                            const Text(
                              'Google 계정으로 로그인',
                              style: TextStyle(fontSize: 16),
                            ),
                            // const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Center(
              child: Column(
                children: [
                  Text(
                    '로그인에 문제가 있는 경우',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '노인복지시설에 문의해 주시기 바랍니다',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

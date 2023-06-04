import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:gsheets/gsheets.dart';
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

  void sheet(var googleUser) async {
    final googleSignIn = GoogleSignIn(
      scopes: <String>[
        'https://www.googleapis.com/auth/spreadsheets',
      ],
    );
    // Authenticate the user
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    // Obtain the authentication token
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final gsheets = GSheets(accessToken);
    // Set up the Google Sheets API client and authenticate with the access token
    final httpClient = http.Client();
    final authClient = authenticatedClient(
      httpClient,
      AccessCredentials(
        AccessToken(
            'Bearer', accessToken!, DateTime.now().add(Duration(hours: 1))),
        'user-agent',
        ['https://www.googleapis.com/auth/spreadsheets'],
      ),
    );

    final sheetsApi = sheets.SheetsApi(authClient);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('로그인'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              semanticLabel: 'information',
            ),
            onPressed: () {},
          ),
        ],
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
                '복지사님 환영합니다',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 24.0),
            Column(
              children: <Widget>[
                Lottie.network(
                  'https://assets1.lottiefiles.com/packages/lf20_khtt8ejx.json',
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

/**
 사용자의 프로필 정보를 표시하고, Firebase를 통해 로그인한 사용자의 정보를 가져오고, QR 코드를 생성하여 사용자 UID를 보여주고, 로그아웃 기능을 제공하는 파일입니다.
 */
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase 인증 기능을 사용하기 위한 패키지입니다.
import 'package:google_sign_in/google_sign_in.dart'; // Google 로그인 기능을 지원하는 패키지입니다.
import 'package:qr_flutter/qr_flutter.dart'; // QR 코드를 생성하기 위한 패키지입니다.

// 프로필 화면을 나타내는 StatelessWidget입니다.
class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key) {
    get_userdata(); // 생성자에서 사용자 데이터를 가져오는 함수를 호출합니다.
  }

  late var name;
  late var uid;
  late var emailAddress;
  late var profilePhoto;
  var login_method = false; // 로그인 방식(true: Google, false: 익명)입니다.
  var coverHeight = 280.0 - 56.0;
  var profileHeight = 96.0;

  // 사용자 데이터를 가져오는 함수입니다.
  void get_userdata() {
    final user = FirebaseAuth.instance.currentUser; // Firebase에서 현재 로그인된 사용자를 가져옵니다.

    if (user != null) {
      for (final providerProfile in user.providerData) {
        login_method = true;
        // ID of the provider (google.com, apple.com, etc.)
        final provider = providerProfile.providerId;
        // UID specific to the provider
        uid = providerProfile.uid!;
        // Name, email address, and profile photo URL
        name = providerProfile.displayName;
        emailAddress = providerProfile.email;
        profilePhoto = providerProfile.photoURL;
      }

      if (login_method == false) {
        uid = user.uid;
        name = 'Jin Su Kim';
        emailAddress = 'Anonymous';
        profilePhoto = 'http://handong.edu/site/handong/res/img/logo.png';
      }
    }
  }

  // 커버 이미지를 생성하는 위젯입니다.
  Widget buildCoverImage() {
    return Image.asset(
      'assets/forest.jpg',
      width: double.infinity, // 화면 전체 너비입니다.
      height: coverHeight,
      fit: BoxFit.cover, // 이미지를 화면에 꽉 차게 표시합니다.
    );
  }

  // 프로필 이미지를 생성하는 위젯입니다.
  Widget buildProfileImage() {
    return CircleAvatar(
      radius: profileHeight / 2,
      backgroundColor: Colors.grey.shade100,
      child: CircleAvatar(
        radius: profileHeight / 2 - 4,
        backgroundImage: NetworkImage(
          profilePhoto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '프로필',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              semanticLabel: 'logout',
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: ListView(
        children: [
          buildTop(),
          buildContent(context),
        ],
      ),
    );
  }

  // 상단 커버 이미지와 프로필 이미지를 포함하는 위젯입니다.
  Widget buildTop() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: profileHeight / 2),
          child: buildCoverImage(),
        ),
        Positioned(
          top: coverHeight - profileHeight / 2,
          child: buildProfileImage(),
        ),
      ],
    );
  }

  // 사용자 이름, 이메일, QR 코드 등 상세 정보를 표시하는 위젯입니다.
  Widget buildContent(context) {
    return Column(
      children: [
        const SizedBox(height: 12.0),
        Text(
          name,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          emailAddress,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12.0),
        Center(
          child: QrImageView(
            data: FirebaseAuth.instance.currentUser!.uid,
            version: QrVersions.auto,
            size: 200,
            gapless: false,
          ),
        ),
      ],
    );
  }
}

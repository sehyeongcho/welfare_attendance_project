import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key) {
    get_userdata();
  }

  late var name;
  late var uid;
  late var emailAddress;
  late var profilePhoto;
  var login_method = false; // true -> goolge , false -> anonymous
  var coverHeight = 280.0 - 56.0;
  var profileHeight = 96.0;

  void get_userdata() {
    final user = FirebaseAuth.instance.currentUser;
    // print('user : ${user}');
    if (user != null) {
      for (final providerProfile in user.providerData) {
        login_method = true;
        // ID of the provider (google.com, apple.com, etc.)
        final provider = providerProfile.providerId;
        print('provider : ${provider}');
        // UID specific to the provider
        uid = providerProfile.uid!;
        // print('uid : ${uid}');
        // Name, email address, and profile photo URL
        name = providerProfile.displayName;
        emailAddress = providerProfile.email;
        profilePhoto = providerProfile.photoURL;
      }
      if (login_method == false) {
        print(' Anonymous sign in');
        uid = user.uid;
        name = 'Jin Su Kim';
        emailAddress = 'Anonymous';
        profilePhoto = 'http://handong.edu/site/handong/res/img/logo.png';
      }
    }
  }

  Widget buildCoverImage() {
    return Image.asset(
      'assets/forest.jpg',
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover,
    );
  }

  Widget buildProfileImage() {
    return CircleAvatar(
      radius: profileHeight / 2,
      backgroundImage: NetworkImage(
        profilePhoto,
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
      // body: ListView(
      //   padding: const EdgeInsets.all(24.0),
      //   shrinkWrap: true,
      //   children: [
      //     SizedBox(
      //       width: 200.0,
      //       height: 200.0,
      //       child: AspectRatio(
      //         aspectRatio: 1 / 1,
      //         child: Image.network(profilePhoto),
      //       ),
      //     ),
      //     const SizedBox(height: 12.0),
      //     Text(
      //       '<$uid>',
      //       style: Theme.of(context).textTheme.bodyLarge,
      //     ),
      //     const SizedBox(height: 12.0),
      //     const Divider(
      //       thickness: 2.0,
      //     ),
      //     const SizedBox(height: 12.0),
      //     Text(
      //       emailAddress,
      //       style: Theme.of(context).textTheme.bodyLarge,
      //     ),
      //     const SizedBox(height: 12.0),
      //     Text(
      //       name,
      //       style: Theme.of(context).textTheme.bodyLarge,
      //     ),
      //     const SizedBox(height: 12.0),
      //     Center(
      //       child: QrImageView(
      //         data: FirebaseAuth.instance.currentUser!.uid,
      //         version: QrVersions.auto,
      //         size: 200,
      //         gapless: false,
      //       ),
      //     )
      //   ],
      // ),
      body: ListView(
        children: [
          buildTop(),
          buildContent(context),
        ],
      ),
    );
  }

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

  Widget buildContent(context) {
    return Column(
      children: [
        const SizedBox(height: 12.0),
        Text(
          name,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12.0),
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

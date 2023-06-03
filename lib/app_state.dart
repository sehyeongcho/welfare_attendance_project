import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApplicationState extends ChangeNotifier {
  late var _whatuser; //복시사용 로그인 = true

  List<String> _classlist=[];
  Map<String, dynamic>? _maplist = Map();// contain bool to check if other teacher take class and excelid

  Map<String, dynamic>? get maplist =>
      _maplist;

  List<String> get classlist => _classlist;

  get whatuser => _whatuser;

  set whatuser(value) {
    _whatuser = value;
  }

  var _exceldata = null;

  get exceldata => _exceldata;

  void getdata(var data) {
    _exceldata = data;
    notifyListeners();
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> classlist_listener() {
    var listen = FirebaseFirestore.instance
        .collection('manager')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      // _number_like = (snapshot.data() as Map<String, dynamic>).keys.toList().length;
      _classlist = snapshot.data()!.keys.toList();
      _classlist.remove('복지사');
      _maplist = snapshot.data();
      _maplist!.remove('복지사'); //remove 복지사 field
      if(_maplist != null)
        _maplist?.forEach((key, value) {
          if(value.first == true) //other teacher already took this class
            _maplist?.remove(key);
        });
      notifyListeners();
    });

    return listen;
  }



  }

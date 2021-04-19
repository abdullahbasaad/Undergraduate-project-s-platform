import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:graduater/models/globals.dart' as globals;

class AuthNotifier with ChangeNotifier{
  FirebaseUser _user;
  FirebaseUser get user => _user;

  void setUser(FirebaseUser user){
    _user = user;
    globals.email = null;
    notifyListeners();
  }
}
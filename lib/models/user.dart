import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {

  int userId;
  String userName;
  String email;
  String password;
  bool   admin;
  
  User ([DocumentSnapshot snapshot]);

  User.fromMap(Map<String, dynamic> data){
    userId = data[userId];
    userName = data['userName'];
    email = data['email'];
    password = data['password'];
    admin = data[admin];
  }
}
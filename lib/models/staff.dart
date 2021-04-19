import 'package:flutter/material.dart';
import 'package:graduater/models/user.dart';

class Staff extends User {

  int staffId;
  String staffName;
  String officeNo;
  String address;

  Staff();

  Staff.fromMap(Map<String, dynamic> data){
    staffId = data[staffId];
    staffName = data['staffName'];
    officeNo = data['officeNo'];
    address = data['address'];
  }

}
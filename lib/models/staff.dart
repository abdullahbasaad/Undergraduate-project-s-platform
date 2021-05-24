import 'package:flutter/material.dart';
import 'package:graduater/models/user.dart';

class Staff extends User {
  String documentId;
  int staffId;
  String staffName;
  String officeNo;
  String address;

  Staff(this.documentId, this.staffId, this.staffName, this.officeNo, this.address);

}
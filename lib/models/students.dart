import 'package:flutter/material.dart';
import 'package:graduater/models/user.dart';

class Students extends User{
  String documentId;
  int studentId;
  String projectId;
  String phoneNo;
  String course;

  Students(this.documentId, this.studentId, this.projectId, this.course, this.phoneNo);

}

import 'package:flutter/material.dart';
import 'package:graduater/models/user.dart';

class Students extends User{
  int studentId;
  String projectId;
  String phoneNo;
  String course;

  Students();

  Students.fromMap(Map<String,dynamic> map){
    studentId = map[studentId];
    projectId = map[projectId];
    phoneNo = map[phoneNo];
    course = map[course];
  }

}

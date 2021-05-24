import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Projects {
  String documentId;
  String pId;
  String projectTitle;
  String projectDesc;
  int proposedBy;
  int supervisor;
  int noOfStudents;
  String supervisorName;
  bool available;
  Timestamp createdDt;
  String category;


  Projects(this.documentId,this.pId,this.projectTitle,this.projectDesc,this.proposedBy,this.supervisor,this.noOfStudents, this.supervisorName, this.available, this.category);
}
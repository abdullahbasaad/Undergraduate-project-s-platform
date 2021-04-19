import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Skills {
  String docId;
  String documentID;
  String skillDesc;
  DateTime createdDt;
  bool selected = false;

  Skills(this.documentID,this.skillDesc);

}


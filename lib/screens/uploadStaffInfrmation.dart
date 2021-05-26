import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduater/api/graduater_api.dart';
import 'package:graduater/components/screenTitleWidget.dart';
import 'package:csv/csv.dart';
import 'package:graduater/models/projects.dart';
import 'package:graduater/models/staff.dart';
import 'package:graduater/models/user.dart';
import 'package:graduater/notifier/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';

class UploadStaffInformation extends StatefulWidget {
  @override
  _UploadStaffInfoState createState() => _UploadStaffInfoState();
}

class _UploadStaffInfoState extends State<UploadStaffInformation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _semicircleController = ScrollController();
  List<List<dynamic>> _data = [];
  List<Staff> _staff =[];

  bool _inserted = false;
  String fileName;
  String path;
  Map<String, String> paths;
  List<String> extensions;
  bool isLoadingPath = false;
  bool isMultiPick = false;
  FileType fileType;

  @override
  void initState(){
    super.initState();
    setState(() {
    });
    //_inserted = false;
  }

  // This function is triggered when the floating button is pressed
  void _loadCSV() async {
    _showStaff();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: ScreenTitleWidget(screenTitle: 'Upload Staff Information'),
      ),
      body: DraggableScrollbar.semicircle(
        controller: _semicircleController,
        child: ListView.builder(
          controller: _semicircleController,
          itemCount: _data.length,
          itemBuilder: (_, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(15.0),
                ),
              ),
              margin: const EdgeInsets.all(3),
              color: index == 0 ? Colors.white54 : Colors.white,
              child: ListTile(
                leading: Icon(Icons.account_circle),
                title: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(_data[index][0].toString(),
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                      SizedBox(height: 2.0,),
                      Container(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text (_data[index][1])
                      ),
                      SizedBox(height: 2.0,),
                      Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(_data[index][2].toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,),
                        ),
                      ),
                      SizedBox(height: 2.0,),
                      Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(_data[index][3].toString(),
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ]
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton:
      FloatingActionButton(child: Icon(Icons.add), onPressed: _loadCSV)
    );
  }

  final spinkit = SpinKitRotatingCircle(
    color: Colors.white,
    size: 50.0,
  );

  _showStaff() async{
    setState(() => isLoadingPath = true);

    try {
      path = await FilePicker.getFilePath(type: fileType != null? fileType: FileType.any, allowedExtensions: extensions);
      paths = null;
    }
    on PlatformException catch (e) {
      Alert(
        context: context,
        title: "Erorr!",
        desc: "Unsupported operation" + e.toString(),
        image: Image.asset("images/fail.png"),
      ).show();
    }

    if (!mounted) return;

    setState(() {
      isLoadingPath = false;
      fileName = path != null ? path
          .split('/')
          .last : paths != null
          ? paths.keys.toString() : '...';
    });

    final input = new File(path).openRead();
    final fields = await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();
    _data = fields;
    setState(() {

    });

    Alert(
      context: context,
      type: AlertType.warning,
      title: "Upload Staff Information",
      desc: "Would you like to save staff info into the database?",
      buttons: [
        DialogButton(
          child: Text(
            "YES",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            _insertStaffInfo(_data);
            if (_inserted)
              Alert(
                context: context,
                title: "Success!",
                desc: _staff.length.toString() +
                    'staff have been inserted',
                image: Image.asset("images/success.png"),
              ).show();
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
      ],
    ).show();
  }

  _insertStaffInfo(List<List<dynamic>> _data) async{
    for (int i=1; i<_data.length; i++) {
      try{
        User user = User();
        user.userId = _data[i][0];
        user.userName = _data[i][1];
        user.email = _data[i][2];
        user.email = user.email.toLowerCase();
        user.password = user.userId.toString()+'0000000';

        AuthNotifier authNotifier = Provider.of<AuthNotifier>(
            context, listen: false);
        await register(user, authNotifier);

        String docId = Uuid().v4();

        Staff staff = Staff(docId, int.parse(_data[i][0].toString()), _data[i][1].toString(), _data[i][3].toString(), _data[i][4].toString());
        _staff.add(staff);
        Firestore.instance.collection("staff").document(docId).setData({
          'staffId': staff.staffId,
          'staffName': staff.staffName,
          'officeNo': staff.officeNo,
          'address': staff.address});

        _inserted = true;
      }catch(e){
        Alert(
          context: context,
          title: "Erorr!",
          desc: "Staff info. already inserted or invalid file format",
          image: Image.asset("images/fail.png"),
        ).show();
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
        break;
      }
    }
    Navigator.pop(context);
  }
}




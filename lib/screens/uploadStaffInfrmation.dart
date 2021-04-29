import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduater/components/screenTitleWidget.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:graduater/models/staff.dart';
import 'package:graduater/models/user.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:graduater/notifier/auth_notifier.dart';
import 'package:graduater/api/graduater_api.dart';

class UploadStaffInformation extends StatefulWidget {
  @override
  _UploadStaffInformationState createState() => _UploadStaffInformationState();
}

class _UploadStaffInformationState extends State<UploadStaffInformation> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _semicircleController = ScrollController();

  List<List<dynamic>> _data = [];
  List<Staff> _staff = [];
  bool _inserted = false;

  // This function is triggered when the floating button is pressed
  void _loadCSV() async {
    final _rawData = await rootBundle.loadString("assets/staff_info.csv");
    List<List<dynamic>> _listData = CsvToListConverter().convert(_rawData);
    setState(() {
      _data = _listData;
      Alert(
        context: context,
        type: AlertType.warning,
        title: "Upload Staff Information",
        desc: "Would you like to save all staff info into database?",
        buttons: [
          DialogButton(
            child: Text(
              "YES",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () async{
              await _uploadStaffInfo();
              if (_staff.length >0)
                Alert(
                    context: context,
                    title: "Success!",
                    desc: _staff.length.toString()+' staff info have been inserted',
                    image: Image.asset("images/success.png"),
                    ).show();
            },
            color: Color.fromRGBO(0, 179, 134, 1.0),
          ),
          DialogButton(
            child: Text(
              "CANCEL",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            gradient: LinearGradient(colors: [
              Color.fromRGBO(116, 116, 191, 1.0),
              Color.fromRGBO(52, 138, 199, 1.0)
            ]),
          )
        ],
      ).show();
    });
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
                        child: Text (_data[index][1],)
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
      FloatingActionButton(child: Icon(Icons.add), onPressed: _loadCSV),
    );
  }

  _uploadStaffInfo() async{
    String skl;
    String lng;
    for (int row=1; row<_data.length; row++){
      try{

        User user = User();
        user.userId = _data[row][0];
        user.userName = _data[row][1];
        user.email = _data[row][2];
        user.password = user.userName.substring(0,2)+'123456';
        user.admin = false;


        AuthNotifier authNotifier = Provider.of<AuthNotifier>(
            context, listen: false);
        await register(user, authNotifier);

        Staff staff = Staff();
        staff.staffId = _data[row][0];
        staff.staffName = _data[row][1];
        staff.officeNo = _data[row][3].toString();
        staff.address = _data[row][4];

        _staff.add(staff);

        Firestore.instance.collection("staff").document().setData(
        {'staffId': staff.staffId,
        'staffName': staff.staffName,
        'officeNo': staff.officeNo,
        'address': staff.address});

      }catch(e){
        Alert(
          context: context,
          title: "Erorr!",
          desc: "Staff Info is already inserted or invalid formatted file!",
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




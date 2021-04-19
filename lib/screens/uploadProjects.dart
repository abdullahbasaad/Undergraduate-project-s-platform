import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduater/api/graduater_api.dart';
import 'package:graduater/components/screenTitleWidget.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:graduater/models/projects.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class UploadProjects extends StatefulWidget {
  @override
  _UploadProjectsState createState() => _UploadProjectsState();
}

class _UploadProjectsState extends State<UploadProjects> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _semicircleController = ScrollController();

  List<List<dynamic>> _data = [];
  List<Projects> _projects = [];
  bool _inserted = false;

  @override
  void initState(){
    super.initState();
    setState(() {
      //_dbHelper = DatabaseHelper.instance;
    });
    _inserted = false;
  }
  // This function is triggered when the floating button is pressed
  void _loadCSV() async {
    final _rawData = await rootBundle.loadString("assets/project_list.csv");
    List<List<dynamic>> _listData = CsvToListConverter().convert(_rawData);
    setState(() {
      _data = _listData;

      Alert(
        context: context,
        type: AlertType.warning,
        title: "Upload projects",
        desc: "Would you like to save all projects in the database?",
        buttons: [
          DialogButton(
            child: Text(
              "YES",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () async{
              await _uploadProjects();
              if (_inserted)
                Alert(
                  context: context,
                  title: "Success!",
                  desc: _projects.length.toString()+' projects have been inserted',
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
        title: ScreenTitleWidget(screenTitle: 'Upload Projects'),
      ),
      body: DraggableScrollbar.semicircle(
        controller: _semicircleController,
        child: ListView.builder(
          controller: _semicircleController,
          itemCount: _data.length,
          itemBuilder: (_, index) {
            return Card(
              margin: const EdgeInsets.all(3),
              color: index == 0 ? Colors.white54 : Colors.white,
              child: ListTile(
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
                      SizedBox(height: 5.0,),
                      Container(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(_data[index][1],)
                      ),
                      SizedBox(height: 20.0,),
                      Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: Text(_data[index][2].toString(),
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

  final spinkit = SpinKitRotatingCircle(
    color: Colors.white,
    size: 50.0,
  );
  _uploadProjects() async{
    for (int row=1; row<_data.length; row++){
      try {
        if (_data[row][0] == null) _data[row][0] = 'No Title';
        if (_data[row][1] == null) _data[row][1] = 'No Description';

        Projects project = Projects(null,_data[row][0],_data[row][1],_data[row][2],_data[row][2],1);
        addProject(project, null);
        _projects.add(project);
        _inserted = true;
      }catch(e){
        Alert(
          context: context,
          title: "Erorr!",
          desc: "Data is already inserted or invalid formatted file!",
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

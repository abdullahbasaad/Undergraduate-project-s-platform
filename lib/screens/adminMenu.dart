import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduater/api/graduater_api.dart';
import 'package:graduater/components/screenTitleWidget.dart';
import 'package:graduater/models/projects.dart';
import 'package:graduater/screens/login.dart';
import 'package:flutter/services.dart';
import 'package:graduater/models/globals.dart' as globals;
import 'package:graduater/screens/showProjects.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'addNewProject.dart';

class AdminMenu extends StatefulWidget {

  final String email;
  AdminMenu({Key key, @required this.email}) : super(key: key);

  @override
  _AdminMenuState createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  // List<Staff> _staff = [];
  List<Projects> _projects = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _semicircleController = ScrollController();
  final _textFieldController = TextEditingController();
  final _textFieldAssignedController = TextEditingController();
  TextEditingController _controller;
  String usrToAdmin;
  int usrUnassign;
  int assignedTo;
  int docLength= 0;
  bool vsbl = false;

  // Function for initiating the page
  @override
  void initState() {
    super.initState();
    setState(() {
    });
    _getAllProjects();
  }

  // Function to build the different components of a page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: ScreenTitleWidget(screenTitle: 'Admin Workspace'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children:  <Widget>[
            Container(
              width: 170.0,
              height: 180.0,
              child:DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                    image: DecorationImage(
                      image: AssetImage("images/bcu.png"),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 95.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person,
                          color: Colors.white),
                      SizedBox(width: 5.0,),
                      Expanded(
                        child:Text((globals.email??'?'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.chat,
                  color: Colors.yellow,),
              title: Text('Chat'),
              onTap: () {
                Navigator.pushNamed(context, '/showRooms');
              },
            ),
            ListTile(
              leading: Icon(Icons.list,
                  color: Colors.blue[900],),
              title: Text('Projects'),
              onTap: () async{
                Navigator.pushNamed(context, '/showProjects');
              },
            ),
            ListTile(
              leading: Icon(Icons.view_headline,
                  color: Colors.blue[900],),
              title: Text('Add New Project'),
              onTap: () async{
                await _awaitCallingProjectDtls(null, 1);
              },
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 0.0),
              child: Divider(
                color: Colors.black),
            ),
            ListTile(
              leading: Icon(Icons.settings,
                  color: Colors.green[900],),
              title: Text('Upload Projects'),
              onTap:() => Navigator.pushNamed(context, '/uploadProjects'),
            ),
            ListTile(
              leading: Icon(Icons.settings,
                  color: Colors.green[900]),
              title: Text('Add New Skills'),
              onTap:() => Navigator.pushNamed(context, '/addSkills'),
            ),
            ListTile(
              leading: Icon(Icons.settings,
                  color: Colors.green[900]),
              title: Text('Add New Programming Language'),
              onTap:() => Navigator.pushNamed(context, '/addLang'),
            ),
            ListTile(
              leading: Icon(Icons.settings,
                  color: Colors.green[900]),
              title: Text('Upload Staff Information'),
              onTap:() => Navigator.pushNamed(context, '/uploadStaffInfo'),
            ),
            ListTile(
              leading: Icon(Icons.settings,
                  color: Colors.green[900]),
              title: Text('Upload Student Information'),
              onTap:() => Navigator.pushNamed(context, '/uploadStudentsInfo'),
            ),
            ListTile(
              leading: Icon(Icons.settings,
                  color: Colors.green[900]),
              title: Text('Export Students & Projects Data'),
              onTap:() => {

                    }),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 0.0),
              child: Divider(
                  color: Colors.black),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Signing-Out'),
              onTap:() async{
                _scaffoldKey.currentState.showSnackBar(
                    SnackBar(duration: new Duration(seconds: 2), content:
                    Row(
                      children: <Widget>[
                        new CircularProgressIndicator(),
                        new Text("  Signing-Out...")
                      ],
                    ),
                    ));
                await Future.delayed(const Duration(seconds: 2));
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                Navigator.of(context).pushAndRemoveUntil(
                  // the new route
                  MaterialPageRoute(
                    builder: (BuildContext context) => Login(),
                  ),
                      (Route route) => false,
                );
              },
            ),
            SizedBox(height: 15.0,),
            FlatButton(
              color: Colors.blue[900],
              textColor: Colors.white,
              child: Text("Unassign a student's project"),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Please enter the student ID'),
                        content: TextField(
                          inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                          onChanged: (value) {
                            setState(() {
                              usrUnassign = int.parse(value);
                            });
                          },
                          controller: _textFieldController,
                          decoration: InputDecoration(hintText: "STUDENT ID"),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            color: Colors.red,
                            textColor: Colors.white,
                            child: Text('CANCEL'),
                            onPressed: () {
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                          ),
                          FlatButton(
                              color: Colors.green,
                              textColor: Colors.white,
                              child: Text('OK'),
                              onPressed: () async {
                                if (await unsignStudentProject(int.parse(_textFieldController.text)))
                                  Alert(
                                    context: context,
                                    title: "Success!",
                                    desc: "The operation has been done successfully",
                                    image: Image.asset("images/success.png"),
                                  ).show();
                                else
                                  Alert(
                                    context: context,
                                    title: "Failed!",
                                    desc: "Student Id incorrect!.",
                                    image: Image.asset("images/fail.png"),
                                  ).show();
                                _textFieldController.text = '';
                              }
                          ),
                        ],
                      );
                    });
              },
            ),
            FlatButton(
              color: Colors.blue[900],
              textColor: Colors.white,
              child: Text("Grant Admin's role to a user"),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Please enter the email address'),
                        content: TextField(
                          onChanged: (value) {
                            setState(() {
                              usrToAdmin = value;
                            });
                          },
                          controller: _textFieldController,
                          decoration: InputDecoration(hintText: "EMAIL ADDRESS"),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            color: Colors.red,
                            textColor: Colors.white,
                            child: Text('CANCEL'),
                            onPressed: () {
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                          ),
                          FlatButton(
                            color: Colors.green,
                            textColor: Colors.white,
                            child: Text('OK'),
                            onPressed: () async {
                              if (await updateUserPrivilege(_textFieldController.text.toLowerCase()))
                                Alert(
                                  context: context,
                                  title: "Success!",
                                  desc: "The user has been updated",
                                  image: Image.asset("images/success.png"),
                                ).show();
                              else
                                Alert(
                                  context: context,
                                  title: "Failed!",
                                  desc: "Email address is not correct!..",
                                  image: Image.asset("images/fail.png"),
                                ).show();
                              _textFieldController.text = '';
                            }
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
      body: Scrollbar(
        showTrackOnHover: true,
        thickness: 12.0,
        isAlwaysShown: true,
        controller: _semicircleController,
        child: ListView.builder(
        controller: _semicircleController,
        itemCount: _projects.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (_, index) {
          return Card(
            margin: const EdgeInsets.all(3),
            child: ListTile(
              leading: GestureDetector(
                child: Icon(Icons.attachment_sharp,
                  color: Colors.black54,),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Assigne to, please enter a student ID'),
                        content: TextField(
                          inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                          onChanged: (value) {
                            setState(() {
                              assignedTo = int.parse(value);
                            });
                          },
                          controller: _textFieldAssignedController,
                          decoration: InputDecoration(hintText: "STUDENT ID"),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            color: Colors.red,
                            textColor: Colors.white,
                            child: Text('CANCEL'),
                            onPressed: () {
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                          ),
                          FlatButton(
                              color: Colors.green,
                              textColor: Colors.white,
                              child: Text('OK'),
                              onPressed: () async {
                                if (_textFieldAssignedController.text.length > 0) {
                                  await assignProject(
                                      _projects[index].documentId,
                                      int.parse(_textFieldAssignedController.text),
                                      _projects[index].noOfStudents);

                                  setState(() {

                                  });
                                }else
                                  Alert(
                                    context: context,
                                    title: "Failed!",
                                    desc: "Please enter a student ID!..",
                                    image: Image.asset("images/fail.png"),
                                  ).show();
                                _textFieldAssignedController.text = '';
                              }
                          ),
                        ],
                      );
                    });
                },
              ),
              title: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(_projects[index].projectTitle,
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),),
                  ),
                  SizedBox(height: 20.0,),
                  Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child:  Text(_projects[index].supervisorName,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                     ),
                  ),
                  SizedBox(height: 10.0,),
                  Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child:  FutureBuilder<String>(
                      future: getStudentAssignedName(_projects[index].documentId),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          return Text('Assigned to : '+snapshot.data,
                            style: TextStyle(
                              color: Colors.green[900],
                              fontSize: 13.0,
                              //fontWeight: FontWeight.bold,
                            ),);
                        }else
                          return Container();
                      },
                    ),
                  ),
                ]
              ),
              trailing: GestureDetector(
                onTap: (){
                  _awaitCallingProjectDtls(_projects[index].documentId,0);
                },
                child: Icon(Icons.apps,
                  color: Colors.blue,),
              ),
            ),
          );
        },
      ),
      ),
    );
  }

  // To fetch all project and store them in a list
  _getAllProjects() async{ // Firestore DB
    _projects = await getProjectsList();
    setState(() {
    });
  }

  // To fetch all project documents
  Future<List<Projects>> getProjectsList() async {
    QuerySnapshot qShot = await getProjectDocuments();
    docLength = qShot.documents.length;
    return qShot.documents.map(
            (doc) => Projects(
            doc.documentID,
            doc.data['pId'],
            doc.data['projectTitle'],
            doc.data['projectDesc'],
            doc.data['proposedBy'],
            doc.data['supervisor'],
            doc.data['noOfStudents'],
            doc.data['supervisorName'],
            doc.data['available'],
            doc.data['category'])
    ).toList();
  }

  // Admin can assign a project to a particular student by using student id
  Future<void> assignProject (String projId, int studId, int noOfStud) async{
    bool suc = false;
    String projectAssigned;
    int stdCount = 0;

    if (await checkStudentExist(studId)){
      projectAssigned = await returnStudentProject(globals.userId);
      stdCount = await getHowManyStudentAssigned(projId);

      if (stdCount < noOfStud) {
        suc = true;
        assignProjectToStudent(studId, projId);

        if (await getHowManyStudentAssigned(projId)+1 == noOfStud ) // curent student
          await updateProjectAvailable(projId, false);

        if (projectAssigned != null) await updateProjectAvailable(projectAssigned, true);
      } else
        Alert(
          context: context,
          title: "Failed!",
          desc: "The project had been choosen!!..",
          image: Image.asset("images/fail.png"),
        ).show();
    }else
      Alert(
        context: context,
        title: "Failed!",
        desc: "Incorrect student ID!..",
        image: Image.asset("images/fail.png"),
      ).show();

    if (suc) {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  // Function to call project details
  Future<void> _awaitCallingProjectDtls(String projDoc, int whoCalled) async {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(duration: new Duration(seconds: 2), content:
        Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text(" Uploading ...")
          ],
        ),
    ));

    bool vis = await checkStudentExist(globals.userId);
    bool asg = false;

    if (projDoc != null){
      DocumentSnapshot ds = await Firestore.instance.collection('project').document(projDoc).get();

      int howManyStudent = ds.data['noOfStudents'];

      if (howManyStudent > await getHowManyStudentAssigned(projDoc))
        asg = true;
    }

    if (whoCalled == 0){
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddNewProject(projectId: projDoc, pageTitle: 'Project Details', vsbl: vis, assigned: asg)
          ));
    }else{
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddNewProject(projectId: null, pageTitle: 'Add New Project', vsbl: false, assigned: asg)
          ));
    }
  }

  void _generateCsvFile() async {
    // Map<Permission, PermissionStatus> statuses = await [
    //   Permission.storage,
    // ].request();
    //
    // List<dynamic> associateList = [
    //   {"number": 1, "lat": "14.97534313396318", "lon": "101.22998536005622"},
    //   {"number": 2, "lat": "14.97534313396318", "lon": "101.22998536005622"},
    //   {"number": 3, "lat": "14.97534313396318", "lon": "101.22998536005622"},
    //   {"number": 4, "lat": "14.97534313396318", "lon": "101.22998536005622"}
    // ];
    //
    // List<List<dynamic>> rows = [];
    //
    // List<dynamic> row = [];
    // row.add("number");
    // row.add("latitude");
    // row.add("longitude");
    // rows.add(row);
    // for (int i = 0; i < associateList.length; i++) {
    //   List<dynamic> row = [];
    //   row.add(associateList[i]["number"] - 1);
    //   row.add(associateList[i]["lat"]);
    //   row.add(associateList[i]["lon"]);
    //   rows.add(row);
    // }
    //
    // String csv = const ListToCsvConverter().convert(rows);
    //
    // String dir = await ExtStorage.getExternalStoragePublicDirectory(
    //     ExtStorage.DIRECTORY_DOWNLOADS);
    // print("dir $dir");
    // String file = "$dir";
    //
    // File f = File(file + "/filename.csv");
    //
    // f.writeAsString(csv);
    //
    // setState(() {
    //   _counter++;
    // });
  }

}

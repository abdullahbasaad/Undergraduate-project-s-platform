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
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';

class UploadProjects extends StatefulWidget {
  @override
  _UploadProjectsState createState() => _UploadProjectsState();
}

class _UploadProjectsState extends State<UploadProjects> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _semicircleController = ScrollController();
  List<Projects> _projects = [];
  List<String> pId = [];
  List<String> projectTitle = [];
  List<String> projectDesc = [];
  List<String> supervisor = [];
  List<int> noOfStudent = [];
  List<String> supervisorNames = [];
  List<String> category = [];
  List<String> skills = [];
  List<String> langs = [];

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
    _inserted = false;
  }

  // This function is triggered when the floating button is pressed
  void _loadCSV() async {
    await showProjects();
    QuerySnapshot qsUsers = await Firestore.instance.collection('user').getDocuments();
    QuerySnapshot qsStaff = await Firestore.instance.collection('staff').getDocuments();

    if (qsUsers.documents.length == 0 || qsStaff.documents.length ==0)
      Alert(
        context: context,
        title: "Erorr!",
        desc: "Staff and student information must be uploaded first!..",
        image: Image.asset("images/fail.png"),
      ).show();
    else {
      setState(()  {
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
              onPressed: () async {
                await _uploadProjects();
                if (_inserted)
                  Alert(
                    context: context,
                    title: "Success!",
                    desc: _projects.length.toString() +
                        ' projects have been inserted',
                    image: Image.asset("images/success.png"),
                  ).show();
              },
              color: Color.fromRGBO(0, 179, 134, 1.0),
            ),
          ],
        ).show();
      });
    }
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
          itemCount: projectTitle.length,
          itemBuilder: (_, index) {
            return Card(
              margin: const EdgeInsets.all(3),
              child: ListTile(
                title: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(projectTitle[index],
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                      SizedBox(height: 15.0,),
                      Container(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(supervisor[index],
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                    ],
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
    String skl;
    String lng;
    int sprvsr;
    for (int row=0; row<projectTitle.length; row++){
      skl='';
      lng='';
      try {
        if (projectTitle[row] == null) projectTitle[row] = 'No Title';
        sprvsr = await getUserId(supervisor[row].toString());

        Projects project = Projects(null,
                                    pId[row].toString(),
                                    projectTitle[row],
                                    projectDesc[row],
                                    sprvsr,
                                    sprvsr,
                                    int.parse(noOfStudent[row].toString()),
                                    supervisor[row].toString(),
                                    true,
                                    category[row]);
        project.documentId = Uuid().v4();
        addProject(project, project.documentId);

        skl = skills[row];
        if (skl.length > 0)
          await insertSkills(skl, project.documentId);

        lng = langs[row];
        if (lng.length > 0)
          await insertLangs(lng, project.documentId);

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

  Future<void> insertSkills(String skl, String prj) async{
    String sen='';
    for(int i=0; i<skl.length; i++) {
      if (skl[i] != ','){
        sen = sen + skl[i];
      }else{
        sen = sen.trim();

        if (! await checkSkillExist(sen))
          await addNewSkillNId(sen);

        await addProjectSkill(prj, sen);
        sen = '';
      }
    }
    sen = sen.trim();
    if (sen.length > 0) {
      if (! await checkSkillExist(sen))
        await addNewSkillNId(sen);
      await  addProjectSkill(prj, sen);
    }
  }
  
  Future<void> insertLangs(String lng, String prj) async{
    String sen='';
    for(int i=0; i<lng.length; i++) {
      if (lng[i] != ','){
        sen = sen + lng[i];
      }else{
        sen = sen.trim();

        if (! await checkLangExist(sen))
          await addNewLangNId(sen);

        await addProjectLang(prj, sen);
        sen = '';
      }
    }
    sen = sen.trim();
    if (sen.length > 0) {
      if (! await checkLangExist(sen))
        await addNewLangNId(sen);
      await  addProjectLang(prj, sen);
    }
  }
  
  showProjects() async{
    clearLists();
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
      fileName = path != null ? path.split('/').last : paths != null
          ? paths.keys.toString() : '...';
    });

    final input = new File(path).openRead();
    final fields = await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();

    for (int i=1; i<fields.length; i++) {
      pId.add(fields[i][0].toString());
      supervisor.add(fields[i][1].toString());
      category.add(fields[i][2].toString());
      projectTitle.add(fields[i][3].toString());
      noOfStudent.add(int.parse(fields[i][4].toString()));
      skills.add(fields[i][5].toString());
      langs.add(fields[i][6].toString());
      projectDesc.add(fields[i][7].toString());
    }
  }

  clearLists(){
    _projects.clear();
    projectTitle.clear();
    projectDesc.clear();
    supervisor.clear();
    noOfStudent.clear();
    pId.clear();
    supervisorNames.clear();
    skills.clear();
    langs.clear();
  }
}

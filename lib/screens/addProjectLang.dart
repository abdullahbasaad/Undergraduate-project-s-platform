import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduater/api/graduater_api.dart';
import 'package:graduater/components/screenTitleWidget.dart';
import 'package:graduater/models/programming_languages.dart';
import 'package:graduater/models/project_languages.dart';
import 'package:graduater/screens/addNewProject.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:graduater/models/globals.dart' as globals;

class AddProjectLangs extends StatefulWidget {

  final String projectDoc;
  AddProjectLangs({@required this.projectDoc});

  @override
  _AddProjectLangsState createState() => _AddProjectLangsState();
}

class _AddProjectLangsState extends State<AddProjectLangs> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ProjectLanguages _projectLangs = ProjectLanguages(null,null);
  static List<ProgrammingLanguages> _langs = [];
  List<ProjectLanguages> _projectLangLst = [];

  @override
  void initState(){
    super.initState();
    setState(() {});
    _refreshProjectLangList(widget.projectDoc);
    _refreshLangList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: <Widget>[
          Row(
            children: [
              IconButton(icon: const Icon(Icons.save,),
                  tooltip: 'Save',
                  iconSize: 33.0,
                  color: Colors.white,
                  highlightColor: Colors.white70,
                  onPressed: () {
                    _onSubmit();
                  }),
              IconButton(icon: const Icon(Icons.arrow_back,),
                  tooltip: 'Save',
                  iconSize: 25.0,
                  color: Colors.white,
                  highlightColor: Colors.white70,
                  onPressed: () {
                    _awaitCallingProjectLangDtls();
                  })
            ],

          )
        ],
        title: ScreenTitleWidget(screenTitle: 'Add Project Languages'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: _langs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                      height: 90,
                      width: double.maxFinite,
                      child: Card(
                        elevation: 7,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                width: 2.0,
                                color: Colors.greenAccent,
                              ),
                            ),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10, top: 5),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                _separateCheckBoxes(index),
                                                Text(_langs[index].langDesc,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _separateCheckBoxes(int index) {
    return Checkbox(
        value: _langs[index].selected,
        onChanged: (val) async{
          if (await checkProgProjectDocuments(widget.projectDoc, _langs[index].langDesc)) {
            Alert(
              context: context,
              title: "Failed!",
              desc: "Language is already inserted!",
              image: Image.asset("images/fail.png"),
            ).show();
          }else{
            setState(() {
              _langs[index].selected = val;
            });
          }
        }
    );
  }

  Future<void> _awaitCallingProjectLangDtls() async {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(duration: new Duration(seconds: 2), content:
        Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text(" Uploading ...")
          ],
        ),
        ));

    final bool vis = await checkStudentExist(globals.userId);
    final bool asg = await checkProjectSelected(widget.projectDoc);
    final result = await Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => AddNewProject(projectId: widget.projectDoc, pageTitle: 'Project Details', vsbl: vis, assigned: asg),
        ));
  }

  Future<List<ProgrammingLanguages>> getAllLangs() async {
    QuerySnapshot qShot = await getProgDocuments();

    return qShot.documents.map(
            (doc) => ProgrammingLanguages(
            doc.documentID,
            doc.data['langDesc'])
    ).toList();
  }

  _refreshLangList() async{
    List<ProgrammingLanguages> x = await getProgList();
    setState(() {
      _langs = x;
    });
  }

  Future<List<ProjectLanguages>> getProjectLangList(String projDoc) async {
    QuerySnapshot qShot = await getLangProjectDocuments(projDoc);

    return qShot.documents.map(
            (doc) => ProjectLanguages(
            doc.data['projDoc'],
            doc.data['langDoc'])
    ).toList();
  }

  _refreshProjectLangList(String projectDoc) async{
    List<ProjectLanguages> x = await getProjectLangList(projectDoc);
    setState(() {
      _projectLangLst = x;
    });
  }

  Future<void> _onSubmit () async{
    bool saved = false;
    for (int i=0; i<_langs.length; i++){
      if (_langs[i].selected){
        await  addProjectLang(widget.projectDoc,_langs[i].langDesc);
        saved = true;
      }
    }
    if (saved) await _awaitCallingProjectLangDtls();

      // Alert(
      //   context: context,
      //   title: "Success!",
      //   desc: "Languages have been inserted",
      //   image: Image.asset("images/success.png"),
      // ).show();
  }
}


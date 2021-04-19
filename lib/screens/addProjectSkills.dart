import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduater/api/graduater_api.dart';
import 'package:graduater/components/screenTitleWidget.dart';
import 'package:graduater/models/project_skills.dart';
import 'package:graduater/models/skills.dart';
import 'package:graduater/screens/addNewProject.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AddProjectSkills extends StatefulWidget {

  final String projectDoc;
  AddProjectSkills({@required this.projectDoc});

  @override
  _AddProjectSkillsState createState() => _AddProjectSkillsState();
}

class _AddProjectSkillsState extends State<AddProjectSkills> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ProjectSkills _projectSkills = ProjectSkills(null,null);
  static List<Skills> _skills = [];
  List<ProjectSkills> _projectSkillLst = [];

  @override
  void initState(){
    super.initState();
    setState(() {});
    _refreshProjectSkillList(widget.projectDoc);
    _refreshSkillList();
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
                    _awaitCallingProjectSkillDtls();
                  })
            ],

          )
        ],
        title: ScreenTitleWidget(screenTitle: 'Add Project Skills'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: _skills.length,
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
                                                Text(_skills[index].skillDesc,
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
        value: _skills[index].selected,
        onChanged: (val) async{
          if (await checkSkillProjectDocuments(widget.projectDoc, _skills[index].skillDesc)) {
            Alert(
              context: context,
              title: "Failed!",
              desc: "Skill is already inserted!",
              image: Image.asset("images/fail.png"),
            ).show();
          }else{
            setState(() {
              _skills[index].selected = val;
            });
          }
        }
    );
  }

  Future<void> _awaitCallingProjectSkillDtls() async {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(duration: new Duration(seconds: 2), content:
        Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text(" Uploading ...")
          ],
        ),
        ));

    final result = await Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => AddNewProject(projectId: widget.projectDoc, pageTitle: 'Project Details'),
        ));
  }

  Future<List<Skills>> getAllSkills() async {
    QuerySnapshot qShot = await getProgDocuments();

    return qShot.documents.map(
            (doc) => Skills(
            doc.documentID,
            doc.data['skillDesc'])
    ).toList();
  }

  _refreshProjectSkillList(String projectDoc) async{
    List<ProjectSkills> x = await getProjectSkillList(projectDoc);
    setState(() {
      _projectSkillLst = x;
    });
  }

  Future<List<ProjectSkills>> getProjectSkillList(String projDoc) async {
    QuerySnapshot qShot = await getSkillProjectDocuments(projDoc);

    return qShot.documents.map(
            (doc) => ProjectSkills(
            doc.data['projDoc'],
            doc.data['skillDesc'])
    ).toList();
  }

  _refreshSkillList() async{
    List<Skills> x = await getSkillList();
    setState(() {
      _skills = x;
    });
  }

  Future<void> _onSubmit () async{
    bool saved = false;
    for (int i=0; i<_skills.length; i++){
      if (_skills[i].selected){
        await  addProjectSkill(widget.projectDoc,_skills[i].skillDesc);
        saved = true;
      }
    }
    if (saved)
      Alert(
        context: context,
        title: "Success!",
        desc: "Languages have been inserted",
        image: Image.asset("images/success.png"),
      ).show();
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:graduater/api/graduater_api.dart';
import 'package:graduater/components/screenTitleWidget.dart';
import 'package:graduater/models/project_languages.dart';
import 'package:graduater/models/project_skills.dart';
import 'package:graduater/models/projects.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:graduater/models/globals.dart' as globals;
import 'package:uuid/uuid.dart';
import '../constant.dart';
import 'addProjectLang.dart';
import 'addProjectSkills.dart';

class AddNewProject extends StatefulWidget {

  final String projectId;
  final String pageTitle;
  AddNewProject({Key key, this.projectId, this.pageTitle}) : super(key: key);

  @override
  _AddNewProjectState createState() => _AddNewProjectState();
}

class _AddNewProjectState extends State<AddNewProject> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  Projects _project = Projects(null,null,null,null,null,null,null,null);
  List<Projects> _projects = [];
  List<ProjectSkills> _projectSkills = [];
  List<ProjectLanguages> _projectLangs = [];

  bool _assigned = false;
  bool projectAvailabe = false;
  String _uName;
  int docProjSkillLength = 0;
  int docProjLangLength = 0;
  int noOfStd = 0;

  final _ctrlProjectTitle = TextEditingController();
  final _ctrlProjectDesc = TextEditingController();
  final _ctrlProposedBy = TextEditingController();
  final _ctrlSupervisor = TextEditingController();
  final _ctrlNoOfStudents = TextEditingController();
  final _ctrlProposedName = TextEditingController();
  final _ctrlSuperviseddName = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
    });
    _projectSkills.clear();
    _projectLangs.clear();

    if (widget.projectId != null){
      _getProjectDts();
      _refreshSkillList(widget.projectId);
      _refreshLangList(widget.projectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: ScreenTitleWidget(screenTitle: widget.pageTitle),
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
              IconButton(icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Save',
                  iconSize: 24.0,
                  color: Colors.white,
                  highlightColor: Colors.white70,
                  onPressed: () async{

                  if (globals.admin)
                    Navigator.pushNamed(context, '/adminMenu');
                  else
                    Navigator.pushNamed(context, '/showProjects');
                  }),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _form(),
            _list(),
            _list2(),
          ],
        ),
      ),
    );
  }

  _form() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _ctrlProjectTitle,
                  readOnly: _checkEditabbleFields(),
                  keyboardType: TextInputType.multiline,
                  style: kTextFormFieldStyleAddProject,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'PROJECT TITLE',
                    focusColor: Colors.blue[900],
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  onChanged: (val) => setState(() => _project.projectTitle = val),
                  validator: (val) => (val.length==0? 'Field is required': null),
                ),
                TextFormField(
                  controller: _ctrlProjectDesc,
                  readOnly: _checkEditabbleFields(),
                  keyboardType: TextInputType.multiline,
                  style: kTextFormFieldStyleAddProject,
                  textAlign: TextAlign.center,
                  maxLines: 10,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'PROJECT DESCRIPTION',
                    focusColor: Colors.blue[900],
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  onChanged: (val) => setState(() => _project.projectDesc = val),
                  validator: (val) => (val.length==0? 'Field is required': null),
                ),
                SizedBox(height: 5.0),
                Text ('Proposed By',
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black,
                  fontWeight: FontWeight.bold,
                ),),
                Row(
                  children: [
                    Container(
                      width: 80.0,
                      child: TextFormField(
                        controller: _ctrlProposedBy,
                        inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                        readOnly: _checkEditabbleFields(),
                        style: kTextFormFieldStyleAddProject,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'ID',
                          focusColor: Colors.blue[900],
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        onChanged: (val) async{
                          if (val != null)
                            _project.proposedBy = int.parse(val);
                             _uName = await getUserName(int.parse(val));
                           if (_uName == null){
                             _ctrlProposedName.text = '';
                           }
                           _ctrlProposedName.text = _uName;
                           setState(() {});
                        },
                        validator: (val) {
                          if (val.length==0){
                          return 'Required!';
                          }else if (_ctrlProposedName.text == '') {
                            return 'Invalid ID';
                          }
                          return null;
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(width: 15.0,),
                    Container(
                      width: 250.0,
                      child: TextFormField(
                        controller: _ctrlProposedName,
                        readOnly: true,
                        style: kTextFormFieldStyleAddProject,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'PROPOSED',
                          focusColor: Colors.blue[900],
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.0,),
                Text ('Supervisor',
                  style: TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),),
                Row(
                  children: [
                    Container(
                      width: 80.0,
                      child: TextFormField(
                        controller: _ctrlSupervisor,
                        inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                        readOnly: _checkEditabbleFields(),
                        style: kTextFormFieldStyleAddProject,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'ID',
                          focusColor: Colors.blue[900],
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        onChanged: (val) async{
                          if (val != null)
                            _project.supervisor = int.parse(val);
                            _uName = await getUserName(_project.supervisor);
                            if (_uName == null)
                              _ctrlSuperviseddName.text = '';
                            else
                              _ctrlSuperviseddName.text = _uName;
                          _project.supervisorName = _uName;
                          setState(() {});
                        },
                        validator: (val) {
                          if (val.length==0)
                            return 'Required!';
                          else if (_ctrlSuperviseddName.text == '')
                            return 'Invalid ID';
                          setState(() {});
                          return null;

                        },
                      ),
                    ),
                    SizedBox(width: 15.0,),
                    Container(
                      width: 250.0,
                      child: TextFormField(
                        controller: _ctrlSuperviseddName,
                        readOnly: true,
                        style: kTextFormFieldStyleAddProject,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'SUPERVISOR',
                          focusColor: Colors.blue[900],
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Text ('Number Of Students',
                  style: TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),),
                Row(
                  children: [
                    Container(
                      width: 90,
                      child: TextFormField(
                        textAlignVertical: TextAlignVertical.top,
                        inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                        controller: _ctrlNoOfStudents,
                        style: kTextFormFieldStyleAddProject,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'STUDENT NUMBER',
                          focusColor: Colors.blue[900],
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        onChanged: (val) => setState(() => _project.noOfStudents =
                            int.tryParse(_ctrlNoOfStudents.text) ?? 1),

                        validator: (val) => (val.length==0? 'Field is required': null),
                      ),
                    ),
                    SizedBox(width: 50.0,),
                    Expanded(
                      child:CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        secondary: const Icon(Icons.assignment_turned_in),
                        title: Text("Assign it to me",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),),
                        checkColor: Colors.white,
                        activeColor: Colors.black,
                        value: _assigned,
                        onChanged: (bool value) async {
                          _assigned = value;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //floatingActionButton:
                    Container(
                      height: 100.0,
                      width: 130.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.blue,
                      ),
                      padding: EdgeInsets.all(20.0),
                      child: GestureDetector(
                        onTap: () async{
                          if ((globals.userId != _project.proposedBy) && (globals.admin != true) && widget.projectId != null){
                            Alert(
                              context: context,
                              title: "Warning!",
                              desc: "Invalid privileges",
                              image: Image.asset("images/fail.png"),
                            ).show();
                          }
                          else
                            if (_project.documentId == null) {
                              _project.documentId = Uuid().v4();
                              await addProject(_project, _project.documentId);
                            }else
                            await _awaitCallingProjectSkillDtls(
                                _project.documentId, 0);
                        },
                        child: Center(
                          child: Text(
                            "ADD\nSKILLS      ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.0,),
                    Container(
                      height: 100.0,
                      width: 130.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.blue,
                      ),
                      padding: EdgeInsets.all(15.0),
                      child: GestureDetector(
                        onTap: () async{
                          if ((globals.userId != _project.proposedBy) &&
                              (globals.admin != true) &&
                              (widget.projectId != null)) {
                            Alert(
                              context: context,
                              title: "Warning!",
                              desc: "Invalid privileges",
                              image: Image.asset("images/fail.png"),
                            ).show();
                          }
                          else
                          if (_project.documentId == null) {
                            _project.documentId = Uuid().v4();
                            _project.supervisorName = await (getUserName(_project.supervisor));
                            _project.available = true;
                            await addProject(_project, _project.documentId);
                          }else
                          await _awaitCallingProjectLangDtls(
                              _project.documentId, 0);

                        },
                        child: Center(
                          child: Text(
                            "ADD\nLANGUAGES",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontSize: 17.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]
            ),
          ),
        ),
        SizedBox(height: 10.0,),
      ]
    ),
  );
  _list() => Container(
    child: Card(
      margin: EdgeInsets.fromLTRB(20.0, 1.0, 20.0, 0),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: EdgeInsets.all(8),
        itemBuilder: (context,index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.list,
                  color: Colors.blue,
                  size: 40.0),
                title: Text (_projectSkills[index].skillDesc,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),),
                trailing: IconButton(icon: Icon(Icons.delete_sweep,color: Colors.blue),
                  onPressed: () async{
                    if ((globals.userId != _project.proposedBy) && (globals.admin != true)){
                      Alert(
                        context: context,
                        title: "Warning!",
                        desc: "Invalid privileges",
                        image: Image.asset("images/fail.png"),
                      ).show();
                    }else
                      Alert(
                        context: context,
                        type: AlertType.warning,
                        title: "Warning Message",
                        desc: "Are you sure?",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            color: Color.fromRGBO(0, 179, 134, 1.0),
                          ),
                          DialogButton(
                            child: Text(
                              "Yes",
                              style: TextStyle(color: Colors.blue[900], fontSize: 20),
                            ),
                            onPressed: () async{
                              await _deleteProjectSkill (_projectSkills[index].projDoc);
                              _refreshSkillList(widget.projectId);
                              Navigator.pop(context);
                            },
                            gradient: LinearGradient(colors: [
                              Color.fromRGBO(116, 116, 191, 1.0),
                              Color.fromRGBO(52, 138, 199, 1.0)
                            ]),
                          ),
                        ],
                      ).show();
                  },
                ),
              ),
              Divider(
                height: 5.0,
              ),
            ],
          );
        },
        itemCount: _projectSkills.length,
      ),
    ),
  );
  _list2() => Container(
    margin: EdgeInsets.only(top: 15.0),
    child: Card(
      margin: EdgeInsets.fromLTRB(20.0, 1.0, 20.0, 20),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: EdgeInsets.all(8),
        itemBuilder: (context,index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.list,
                    color: Colors.blue,
                    size: 40.0),
                title: Text(_projectLangs[index].langDesc,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),),
                trailing: IconButton(icon: Icon(Icons.delete_sweep,color: Colors.blue),
                  onPressed: () async{
                    if ((globals.userId != _project.proposedBy) && (globals.admin != true)){
                      Alert(
                        context: context,
                        title: "Warning!",
                        desc: "Invalid privileges",
                        image: Image.asset("images/fail.png"),
                      ).show();
                    }else
                      Alert(
                        context: context,
                        type: AlertType.warning,
                        title: "Warning Message",
                        desc: "Are you sure?",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            color: Color.fromRGBO(0, 179, 134, 1.0),
                          ),
                          DialogButton(
                            child: Text(
                              "Yes",
                              style: TextStyle(color: Colors.blue[900], fontSize: 20),
                            ),
                            onPressed: () async{
                              await _deleteProjectLangDocument(_projectLangs[index].projDoc);
                              _refreshLangList(widget.projectId);
                              Navigator.pop(context);
                            },
                            gradient: LinearGradient(colors: [
                              Color.fromRGBO(116, 116, 191, 1.0),
                              Color.fromRGBO(52, 138, 199, 1.0)
                            ]),
                          ),
                        ],
                      ).show();
                  },
                ),
              ),
              Divider(
                height: 5.0,
              ),
            ],
          );
        },
        itemCount: _projectLangs.length,
      ),
    ),
  );

  Future<List<ProjectSkills>> getProjectSkillList() async {
    QuerySnapshot qShot = await getProjectSkills(widget.projectId);
    docProjSkillLength = qShot.documents.length;

    return qShot.documents.map(
            (doc) => ProjectSkills(
            doc.documentID,
            doc.data['skillDesc'])
    ).toList();
  }

  _refreshSkillList(String projectId) async{
    List<ProjectSkills> x = await getProjectSkillList();
    setState(() {
      _projectSkills = x;
    });
  }

  Future<List<ProjectLanguages>> getProjectLangList() async {
    QuerySnapshot qShot = await getProjectLangs(widget.projectId);
    docProjLangLength = qShot.documents.length;

    return qShot.documents.map(
            (doc) => ProjectLanguages(
            doc.documentID,
            doc.data['langDesc'])
    ).toList();
  }

  _refreshLangList(String projectId) async{
    List<ProjectLanguages> x = await getProjectLangList();
    setState(() {
      _projectLangs = x;
    });
  }

  _resetForm(){
    _formKey.currentState.reset();
    _ctrlProjectTitle.clear();
    _ctrlProjectDesc.clear();
    _ctrlProposedBy.clear();
    _ctrlSupervisor.clear();
    _ctrlNoOfStudents.clear();
  }

  Future<void> _awaitCallingProjectSkillDtls(String projId, int whoCalled) async {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(duration: new Duration(seconds: 2), content:
        Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text(" Uploading ...")
          ],
        ),
        ));
    if (whoCalled == 0){
      final result = await Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(
            builder: (context) => AddProjectSkills(projectDoc: projId),
          ), (route) => false);
    }
  }

  Future<int> _chooseProject () async{
    if (widget.projectId != null)
      return await getHowManyStudentAssigned(widget.projectId);
    else
      return 0;
  }

  Future<void> _deleteProjectLangDocument (String documentID) {
    return Firestore.instance.collection('projectLanguages').document(documentID).delete();
  }

  Future<void> _awaitCallingProjectLangDtls(String projId, int whoCalled) async {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(duration: new Duration(seconds: 2), content:
        Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text(" Uploading ...")
          ],
        ),
        ));
    if (whoCalled == 0){
      final result = await Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(
            builder: (context) => AddProjectLangs(projectDoc: projId),
          ), (route) => false);
    }
  }

  _onSubmit() async{
    var form = _formKey.currentState;
    if (form.validate()) {
      if (_assigned) {
        await _checkAssigneeProject();
      }
      else
        if (_project.documentId != null) {
          if ((globals.userId != _project.proposedBy) && (globals.admin != true)
              && (_project.projectDesc != null))
            Alert(
              context: context,
              title: "Warning!",
              desc: "Invalid privileges",
              image: Image.asset("images/fail.png"),
            ).show();
          else if (!await checkStaffDocument(_project.supervisor))
            Alert(
              context: context,
              title: "Failed!",
              desc: "Must be entered supervisor Id!.",
              image: Image.asset("images/fail.png"),
            ).show();
          else if (_project.supervisor == null || _project.proposedBy == null)
            Alert(
              context: context,
              title: "Failed!",
              desc: "Proposed by and Supervisor are required fields!..",
              image: Image.asset("images/fail.png"),
            ).show();
          else {
            await updateProjectDocument(_project, _project.documentId);
            Alert(
              context: context,
              title: "Success!",
              desc: "Project has been updated",
              image: Image.asset("images/success.png"),
            ).show();
          }
        }else {
          _project.documentId = Uuid().v4();
          _project.available = true;
          _project.supervisorName = await (getUserName(_project.supervisor));
          await addProject(_project, _project.documentId);
          Alert(
            context: context,
            title: "Success!",
            desc: "Project has been updated",
            image: Image.asset("images/success.png"),
          ).show();
        }
    }
  }

  _checkEditabbleFields(){
    if (widget.projectId != null && globals.admin != true)
      return true;
    else
      return false;
  }

  _getProjectDts() async{
    DocumentSnapshot  progObj = await getProjectDoc(widget.projectId);
    _ctrlProjectTitle.text = progObj.data['projectTitle'];
    _ctrlProjectDesc.text = progObj.data['projectDesc'];
    _ctrlNoOfStudents.text = progObj.data['noOfStudents'].toString();
    _ctrlProposedBy.text = progObj.data['proposedBy'].toString();
    _ctrlProposedName.text = await getUserName(progObj.data['proposedBy']);
    _ctrlSupervisor.text = progObj.data['supervisor'].toString();
    _ctrlSuperviseddName.text = await getUserName(progObj.data['supervisor']);

    _project.documentId = progObj.documentID;
    _project.projectTitle = progObj.data['projectTitle'];
    _project.projectDesc = progObj.data['projectDesc'];
    _project.supervisor = progObj.data['supervisor'];
    _project.proposedBy = progObj.data['proposedBy'];
    _project.noOfStudents =progObj.data['noOfStudents'];
    _project.supervisorName =progObj.data['supervisorName'];
    _project.available =progObj.data['available'];

    return _project;
  }

  Future<void> _deleteProjectSkill (String skillDoc) {
    return Firestore.instance.collection('projectSkills').document(skillDoc).delete();
  }

  _checkAssigneeProject() async {
    if (_assigned) {
      if (await checkStudentExist(globals.userId)) {
        if (! await isStudentHasProject(globals.userId)){
          Alert(
            context: context,
            title: "Failed!",
            desc: "You already have a project, please contact the admin.",
            image: Image.asset("images/fail.png"),
          ).show();
          _assigned = false;
        }
        else
          if (await getHowManyStudentAssigned(_project.documentId) >=
              _project.noOfStudents) {
            Alert(
              context: context,
              title: "Failed!",
              desc: "The project is not available, it had chosen by a student",
              image: Image.asset("images/fail.png"),
            ).show();
            _assigned = false;
        } else {
          await assignProjectToStudent(globals.userId, _project.documentId);
          await updateProjectAvailable(_project.documentId, false);
          Alert(
            context: context,
            title: "Success!",
            desc: "The project has been assigned successfully",
            image: Image.asset("images/success.png"),
          ).show();
        }
      } else {
        Alert(
          context: context,
          title: "Failed!",
          desc: "Just students can choose projects.",
          image: Image.asset("images/fail.png"),
        ).show();
        _assigned = false;
      }
      setState(() {});
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduater/api/graduater_api.dart';
import 'package:graduater/models/programming_languages.dart';
import 'package:graduater/models/project_languages.dart';
import 'package:graduater/models/project_skills.dart';
import 'package:graduater/models/projects.dart';
import 'package:graduater/models/skills.dart';
import 'package:graduater/notifier/auth_notifier.dart';
import 'package:graduater/components/screenTitleWidget.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:graduater/models/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:graduater/screens/showRooms.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'addNewProject.dart';

class ShowProjects extends StatefulWidget {
  @override
  _ShowProjectsState createState() => _ShowProjectsState();
}

class _ShowProjectsState extends State<ShowProjects> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _semicircleController = ScrollController();
  List<Projects> _projects = [];
  List<String> _queryProjects = [];
  List<Skills> _skills = [];
  List<ProjectSkills> _projectSkills = [];
  List<ProjectLanguages> _projectLangs = [];
  List<String> _skillsList =['Select a skill...'];
  String _selectedSkill;
  List<ProgrammingLanguages> _langs = [];
  List<String> _langsList =['Select a language...'];
  String _selectedLang;
  bool skillsFound = false;
  bool langsFound = false;
  bool visible = false;

  final _ctrlSkillId = TextEditingController();
  final _ctrlLangId = TextEditingController();
  String str;

  @override
  void initState(){
    super.initState();
    setState(() {

    });
    skillsFound = false;
    langsFound = false;
    _queryProjects.clear();
    _projectSkills.clear();
    _projectLangs.clear();
    _projects.clear();
    _getAllProjects();
    _refreshSkillList();
    _refreshLangList();

  }
  static const TextStyle optionStyle =
  TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: My Project',
      style: optionStyle,
    ),
    Text(
      'Index 2: Chat',
      style: optionStyle,
    ),
    Text(
      'Index 3: New Project',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) async{
    _selectedIndex = index;
    if (_selectedIndex == 2) {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShowRooms()
          ));
      _selectedIndex = 0;
    }else
    if (_selectedIndex == 3){
      await _awaitCallingProjectDtls(null, 1);
      _selectedIndex = 0;
    }

    else if (_selectedIndex == 1) {
      callMyProject();
      _selectedIndex = 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: ScreenTitleWidget(screenTitle: 'Projects'),
        actions: <Widget>[
          Visibility(
            child: IconButton(icon: const Icon(Icons.arrow_back),
                tooltip: 'Back Admin menu',
                iconSize: 24.0,
                color: Colors.white,
                highlightColor: Colors.white70,
                onPressed: () async{
                    Navigator.pushNamed(context, '/adminMenu');
                }),
            visible: globals.admin?true:false,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children:  <Widget>[
            Container(
              width: 170.0,
              height: 220.0,
              child:DrawerHeader(
                decoration: BoxDecoration(
                    color: Colors.blue[900],
                    image: DecorationImage(
                        image: AssetImage("images/bcu.png"),
                    )
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 120.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person,
                        color: Colors.white),
                      SizedBox(width: 5.0,),
                      Expanded(
                        child:Text(
                          (globals.email??'?'),
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
            SizedBox(height: 15.0,),
            Column(
              children: [
                DropdownButton<String>(
                  value: _selectedLang,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 20,
                  elevation: 16,
                  style: TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      _selectedLang = newValue;
                    });
                  },
                  items: _langsList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 5.0,),
                DropdownButton<String>(
                  value: _selectedSkill,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 20,
                  elevation: 16,
                  style: TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      _selectedSkill = newValue;
                    });
                  },
                  items: _skillsList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10.0,),
                Container(
                  height: 40.0,
                  margin: EdgeInsets.fromLTRB(30.0,0.0,30.0,20.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(20.0),
                    shadowColor: Colors.blueGrey,
                    color: Colors.blue,
                    child: GestureDetector(
                      onTap: () async{
                        _queryProjects.clear();
                        if (_skillsList.indexOf(_selectedSkill) != 0)
                          await _refreshQuerySkillList(_selectedSkill);

                        if (_langsList.indexOf(_selectedLang) != 0)
                          await _refreshQuerylangList(_selectedLang);

                        if ((_skillsList.indexOf(_selectedSkill) == 0) && (_langsList.indexOf(_selectedLang) == 0))
                          _getAllProjects();

                        _projectsQuery();
                        Navigator.of(context).pop();
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.pink,
                              size: 24.0,
                            ),
                            SizedBox(width: 10.0,),
                            Text(
                                'SEARCH',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Montserrat'
                                )
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.0,),
                ListTile(
                  leading: Icon(Icons.assignment,
                  color: Colors.blue[900],),
                  title: Text('Add New Project'),
                  onTap: () async{
                    await _awaitCallingProjectDtls(null, 1);
                  },
                ),
                SizedBox(height: 5.0,),
                ListTile(
                  leading: Icon(Icons.list,
                    color: Colors.blue[900],),
                  title: Text('Upload Projects'),
                  onTap: () async{
                    print(globals.admin);
                    if ((await checkStaffDocument(globals.userId)) || (globals.admin))
                      Navigator.pushNamed(context, '/uploadProjects');
                    else
                      Alert(
                        context: context,
                        title: "Error!",
                        desc: "You do not have a privilege.. !",
                        image: Image.asset("images/fail.png"),
                      ).show();
                  },
                ),
                SizedBox(height: 2.0,),
                ListTile(
                  leading: Icon(Icons.chat,
                  color: Colors.yellow),
                  title: Text('Chat'),
                  onTap: () {
                    Navigator.pushNamed(context, '/showRooms');
                  },
                ),
                SizedBox(height: 2.0,),
                ListTile(
                  leading: Icon(Icons.assignment_turned_in,
                  color: Colors.deepOrange,),
                  title: Text('My Project'),
                  onTap: () {
                    callMyProject();
                  }
                ),
                SizedBox(height: 2.0,),
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
                    AuthNotifier authNotifier = Provider.of<AuthNotifier>(
                        context, listen: false);
                    signOut(authNotifier);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: DraggableScrollbar.semicircle(
        controller: _semicircleController,
        child: ListView.builder(
          controller: _semicircleController,
          itemCount: _projects.length,
          itemBuilder: (_, index) {
            return GestureDetector(
              onTap: () async{
                await _awaitCallingProjectDtls(_projects[index].documentId, 0);
              },
              child: Card(
              margin: const EdgeInsets.all(3),
              color: Colors.blue[50],
              child: ListTile(
                title: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        verticalDirection: VerticalDirection.down,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            padding: EdgeInsets.only(top:8),
                            child: Text((index+1).toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[900],
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                          SizedBox(width: 10.0,),
                          Expanded(
                            child: Text(_projects[index].projectTitle,
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),),
                          ),
                        ],
                      )
                    ),
                    SizedBox(height: 10.0,),
                    Container(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child:  FutureBuilder<String>(
                        future: getUserName(_projects[index].supervisor), // a previously-obtained Future<String> or null
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasData) {
                            return Text(snapshot.data,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),);
                          }else
                            return Container();
                        },
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
              ),
            ),
           );
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            title: Text("My Project"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            title: Text("Chat"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            title: Text("New Project"),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red[900],
        showUnselectedLabels: true,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.red[200],
        onTap: _onItemTapped,
      ),
    );
  }

  _form() => Container(
    //color: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5.0),
    child: Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250.0,
            height: 30.0,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
            ),
            child: DropdownButton(
              isExpanded: true,
              value: _selectedSkill,
              onChanged: (newValue) {
                setState(() {
                  _selectedSkill = newValue;
                });
              },
              items: _skillsList.map((val){
                return new DropdownMenuItem<String>(
                  value: val,
                  child: new Text(val,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900]
                    ),),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            width: 250.0,
            height: 30.0,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.0, style: BorderStyle.solid,color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
            ),
            child: DropdownButton(
              isExpanded: true,
              value: _selectedLang,
              onChanged: (newValue) {
                setState(() {
                  _selectedLang = newValue;
                });
              },
              items: _langsList.map((val){
                return new DropdownMenuItem<String>(
                  value: val,
                  child: new Text(val,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900]
                  ),),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 5.0,),
          Container(
            width: 250.0,
            padding: EdgeInsets.all(5.0),
            child: Container(
              height: 40.0,
              margin: EdgeInsets.fromLTRB(30.0,0.0,30.0,5.0),
              child: Material(
                borderRadius: BorderRadius.circular(20.0),
                shadowColor: Colors.blueGrey,
                color: Colors.blue,
                child: GestureDetector(
                  onTap: () {

                  },
                  child: Center(
                    child: Text(
                      'RUN',
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
            ),
          ),
        ]
      ),
    ),
  );

  _getAllProjects() async{ // Firestore DB
    _projects = await getProjectsList();

    setState(() {

    });
  }

  Future<List<Projects>> getProjectsList() async {
    QuerySnapshot qShot = await getProjectDocuments();

    return qShot.documents.map(
            (doc) => Projects(
            doc.documentID,
            doc.data['projectTitle'],
            doc.data['projectDesc'],
            doc.data['proposedBy'],
            doc.data['supervisor'],
            doc.data['noOfStudents'])
    ).toList();
  }

  _refreshSkillList() async{
    List<Skills> x = await getSkillList();
    setState(() {
      _skills = x;
    });
    _skillsList.addAll(_skills.map((e) => e.skillDesc).toList());
    _selectedSkill = _skillsList[0];
  }

  _refreshLangList() async{
    List<ProgrammingLanguages> x = await getProgList();
    setState(() {
      _langs = x;
    });
    _langsList.addAll(_langs.map((e) => e.langDesc).toList());
    _selectedLang = _langsList[0];
  }

  Future<void> _awaitCallingProjectDtls(String projId, int whoCalled) async {
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
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddNewProject(projectId: projId, pageTitle: 'Project Details')
          ));
    }else{
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddNewProject(projectId: null, pageTitle: 'Add New Project')
          ));
    }
  }

  Future<List<ProjectSkills>> getProjectSkillList(String skillDesc) async {
    QuerySnapshot qShot = await returnProjectsWithSpecifcSkill(skillDesc);

    if (qShot.documents.length > 0)
      return qShot.documents.map(
              (doc) => ProjectSkills(
              doc.documentID,
              doc.data['skillDesc'])
      ).toList();
  }

  _refreshQuerySkillList(String skillDesc) async{
    List<ProjectSkills> x = await getProjectSkillList(skillDesc);
    setState(() {
      if (x == null) skillsFound = false;
      else {
        skillsFound = true;
        _projectSkills = x;
      }
    });
  }
  Future<List<ProjectLanguages>> getProjectLangList(String langDesc) async {
    QuerySnapshot qShot = await returnProjectsWithSpecifcLang(langDesc);

    if (qShot.documents.length > 0)
      return qShot.documents.map(
              (doc) => ProjectLanguages(
              doc.documentID,
              doc.data['langDesc'])
      ).toList();
  }

  _refreshQuerylangList(String langDesc) async {
    List<ProjectLanguages> x = await getProjectLangList(langDesc);
    setState(() {
      if (x == null) langsFound = false;
      else {
        langsFound = true;
        _projectLangs = x;
      }
    });
  }

  _projectsQuery() async{
    _projects.clear();
    if (_selectedSkill != _skillsList[0]) {
      if (skillsFound){
        for (ProjectSkills prSk in _projectSkills) {
          Projects project = await returnProjectSkillQueryDocuments(
              prSk.projDoc);
          _projects.add(project);
        }
      }
    }

    if (_selectedLang != _langsList[0]){
      if (langsFound) {
        for (ProjectLanguages prLn in _projectLangs) {
          Projects project = await returnProjectLangQueryDocuments(
              prLn.projDoc);
          _projects.add(project);
        }
      }
    }

    if ((_selectedSkill == _skillsList[0]) && (_selectedLang == _langsList[0])){
      _getAllProjects();
    }
    setState(() {});
  }

  Future<void> callMyProject() async{
    if (! await checkStudentExist(globals.userId)){
      Alert(
        context: context,
        title: "Error!",
        desc: "This option just for students",
        image: Image.asset("images/fail.png"),
        ).show();
        _selectedIndex = 0;
    }else
    if (await isStudentHasProject(globals.userId)) {
      Alert(
        context: context,
        title: "Error!",
        desc: "No project assigned to you yet!",
        image: Image.asset("images/fail.png"),
      ).show();
      _selectedIndex = 0;
    }else {
      String projObj = await returnStudentProject(globals.userId);
      if (projObj != null) {
        await _awaitCallingProjectDtls(projObj, 0);
        _selectedIndex = 0;
      }
    }
  }
}

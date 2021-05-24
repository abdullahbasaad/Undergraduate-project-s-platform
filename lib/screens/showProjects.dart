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
  List<Projects> _tempProjects = [];
  List<String> _queryProjects = [];
  List<Skills> _skills = [];
  List<ProjectSkills> _projectSkills = [];
  List<ProjectLanguages> _projectLangs = [];
  List<String> _skillsList =['Select a skill...'];
  List<String> _staffList =['Select a supervisor...'];

  List<String> _categoryList =['Select a category...'];
  String _selectedCategory;

  String _selectedSkill;
  String _selectedStaff;
  List<ProgrammingLanguages> _langs = [];
  List<String> _langsList =['Select a language...'];
  String _selectedLang;
  bool skillsFound = false;
  bool langsFound = false;
  bool visible = false;
  bool isSwitched = false;
  static bool showButtons = false;
  String str;

  @override
  void initState(){
    super.initState();
    setState(() {  });
    _showHideButtons();
    skillsFound = false;
    langsFound = false;
    _queryProjects.clear();
    _projectSkills.clear();
    _projectLangs.clear();
    _projects.clear();
    _categoryList.clear();
    _tempProjects.clear();
    _getAllProjects();
    _refreshSkillList();
    _refreshLangList();
    _refreshStaffList();
    _getCategoryList();
  }

  static const TextStyle optionStyle =
  TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Visibility(
      visible: showButtons,
      child: Text(
        'Index 1: My Project',
        style: optionStyle,
      ),
    ),
    Text(
      'Index 2: Chat',
      style: optionStyle,
    ),
    Visibility(
      visible: !showButtons,
      child: Text(
        'Index 3: New Project',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
      ),
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
      if (!showButtons)
        await _awaitCallingProjectDtls(null, 1);
    _selectedIndex = 0;
    }

    else if (_selectedIndex == 1) {
      if (showButtons==true)
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
                highlightColor: Colors.white,
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
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.0,),
            Column(
                children: [
                  Container(
                    height: 35.0,
                    margin: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 30.0),
                    color: Colors.yellow,
                    child:  FutureBuilder<String>(
                      future: _getBannerInfo(), // a previously-obtained Future<String> or null
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          return Center(
                            child: Text(snapshot.data,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),),
                          );
                        }else
                          return Container();
                      },
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedLang,
                      icon: Icon(Icons.arrow_drop_down_circle_outlined),
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
                  ),
                  SizedBox(height: 5.0,),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedSkill,
                      icon: Icon(Icons.arrow_drop_down_circle_outlined),
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
                  ),
                  SizedBox(height: 5.0,),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0,0,20.0,0),
                    child: DropdownButton<String>(
                      value: _selectedStaff,
                      icon: Icon(Icons.arrow_drop_down_circle_outlined),
                      iconSize: 20,
                      elevation: 16,
                      style: TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          _selectedStaff = newValue;
                        });
                      },
                      items: _staffList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 5.0,),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0,0,20.0,0),
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      icon: Icon(Icons.arrow_drop_down_circle_outlined),
                      iconSize: 20,
                      elevation: 16,
                      style: TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      items: _categoryList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 5.0,),
                  Container(
                    margin: EdgeInsets.fromLTRB(30.0, 20.0, 0, 30.0),
                    child: Row(
                      children: [
                        Text('Available ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                          ),
                        ),
                        Switch(
                          value: isSwitched,
                          onChanged: (value) {
                            setState(() {
                              isSwitched = value;
                            });
                          },
                          activeTrackColor: Colors.yellow,
                          activeColor: Colors.orangeAccent,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0,),
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
                          _projectSkills.clear();
                          _projectLangs.clear();

                          if (_skillsList.indexOf(_selectedSkill) != 0)
                            await _refreshQuerySkillList(_selectedSkill);

                          if (_langsList.indexOf(_selectedLang) != 0)
                            await _refreshQuerylangList(_selectedLang);

                          if ((!isSwitched) && (_skillsList.indexOf(_selectedSkill) == 0) && (_langsList.indexOf(_selectedLang) == 0)
                              && (_staffList.indexOf(_selectedStaff) == 0) && (_categoryList.indexOf(_selectedCategory) == 0))
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0,),
                  Container(
                    height: 40.0,
                    margin: EdgeInsets.fromLTRB(30.0,0.0,30.0,20.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      shadowColor: Colors.blueGrey,
                      color: Colors.blue[900],
                      child: GestureDetector(
                        onTap: () async{
                          _selectedStaff = _staffList[0];
                          _selectedCategory = _categoryList[0];
                          _selectedSkill = _skillsList[0];
                          _selectedLang = _langsList[0];
                          isSwitched = false;
                          _getAllProjects();
                          setState(() { });
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: Text('REFRESH',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Montserrat'
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0,),
                  Visibility(
                    visible: showButtons==true?false:true,
                    child: ListTile(
                      leading: Icon(Icons.assignment,
                        color: Colors.blue[900],),
                      title: Text('Add New Project'),
                      onTap: () async{
                        await _awaitCallingProjectDtls(null, 1);
                      },
                    ),
                  ),
                  SizedBox(height: 5.0,),
                  Visibility(
                    visible: showButtons==true?false:true,
                    child: ListTile(
                      leading: Icon(Icons.list,
                        color: Colors.blue[900],),
                      title: Text('Upload Projects'),
                      onTap: () async{
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
                  Visibility(
                    visible: showButtons==true?true:false,
                    child: ListTile(
                        leading: Icon(Icons.assignment_turned_in,
                          color: Colors.deepOrange,),
                        title: Text('My Project'),
                        onTap: () {
                          callMyProject();
                        }
                    ),
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
      body: Scrollbar(
        showTrackOnHover: true,
        thickness: 12.0,
        isAlwaysShown: true,
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
                                child: Text(_projects[index].pId,
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
                        child:  Text(_projects[index].supervisorName,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),),

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
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            icon: Visibility(
              visible: showButtons,
                child: Icon(Icons.assignment_turned_in)
            ),
            title: Text("My Project",
            style: TextStyle(color: showButtons==false?Colors.white:Colors.red[200]),),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            title: Text("Chat"),
          ),
          BottomNavigationBarItem(
            icon: Visibility(
              visible: !showButtons,
                child: Icon(Icons.add_circle)),
            title: Text("New Project",
            style: TextStyle(color: showButtons==false? Colors.red[200]:Colors.white),),
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

  Future<String> _getBannerInfo() async { // Firestore DB
    QuerySnapshot avail = await getProjectAvailableDocuments(true);
    int availableCount = avail.documents.length;
    QuerySnapshot allProj = await getProjectDocuments();
    int projectsCount = allProj.documents.length;

    return "Available projects: "+ availableCount.toString()+  " of "+ projectsCount.toString();
  }

  _getAllProjects() async{ // Firestore DB
    _projects = await getProjectsList();
    _projects.sort((a, b) => int.parse(a.pId).compareTo(int.parse(b.pId)));
    setState(() {});
  }

  Future<List<Projects>> getProjectsList() async {
    QuerySnapshot qShot = await getProjectDocuments();

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

  _getCategoryList() async {
    QuerySnapshot qShot = await getProjectDocuments();

    for (int row=0; row<qShot.documents.length; row++){
      _categoryList.add(qShot.documents[row].data['category']);
    }
    _selectedCategory = _categoryList[0];
    _categoryList = _categoryList.toSet().toList();
  }

  _getAllSuperProjects(String spr) async{ // Firestore DB
    _projects.addAll(await getProjectsSupervisorList(spr));
    setState(() {});
  }

  Future<List<Projects>> getProjectsSupervisorList(String spr) async {
    QuerySnapshot qShot = await getProjectSupervisorDocuments(spr);
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

  Future<List<Projects>> getProjectsAvailableList() async {
    QuerySnapshot qShot = await getProjectAvailableDocuments(true);
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

  _getAllAvailableProjects() async { // Firestore DB
    _projects.addAll(await getProjectsAvailableList());
    setState(() {});
  }

  Future<List<Projects>> getProjectsCategoryList(String cat) async {
    QuerySnapshot qShot = await getProjectCategoryDocuments(cat);
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

  _getAllCatProjects(String cat) async { // Firestore DB
    _projects.addAll(await getProjectsCategoryList(cat));
    setState(() {});
  }

  _refreshSkillList() async{
    List<Skills> x = await getSkillList();
    setState(() {
      _skills = x;
    });
    _skillsList.addAll(_skills.map((e) => e.skillDesc).toList());
    _selectedSkill = _skillsList[0];
    _skillsList = _skillsList.toSet().toList();
  }

  _refreshStaffList() async{
    QuerySnapshot qShot = await getStaffDocuments();

    for (int row=0; row<qShot.documents.length; row++){
      _staffList.add(qShot.documents[row].data['staffName']);
    }
    _selectedStaff = _staffList[0];
    _staffList = _staffList.toSet().toList();
  }

  _refreshLangList() async{
    List<ProgrammingLanguages> x = await getProgList();
    setState(() {
      _langs = x;
    });
    _langsList.addAll(_langs.map((e) => e.langDesc).toList());
    _selectedLang = _langsList[0];
    _langsList = _langsList.toSet().toList();
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

    bool vis = await checkStudentExist(globals.userId);
    bool asg = await checkProjectSelected(projId);
    if (whoCalled == 0){
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddNewProject(projectId: projId, pageTitle: 'Project Details', vsbl: vis, assigned: asg)
          ));
    }else{
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddNewProject(projectId: null, pageTitle: 'Add New Project', vsbl: false, assigned: asg)
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
    _queryProjects.clear();
    _tempProjects.clear();

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

    if ((_categoryList.indexOf(_selectedCategory) != 0) && ((_selectedLang != _langsList[0] || _selectedSkill != _skillsList[0]))){
      print(_projects.length);
      print(_selectedCategory);
      for (Projects prj in _projects) {
        print(prj.supervisorName);
        if (prj.category == _selectedCategory)
          _tempProjects.add(prj);
        }
      _projects.clear();
      _projects.addAll(_tempProjects);
    }

    if (_selectedStaff != _staffList[0]){
      _getAllSuperProjects(_selectedStaff);
    }

    if ((! isSwitched) && (_selectedSkill == _skillsList[0]) && (_selectedLang == _langsList[0])
        && (_selectedStaff == _staffList[0]) && (_selectedCategory == _categoryList[0])){
      _getAllProjects();
    }

    if ((! isSwitched) && (_selectedSkill == _skillsList[0]) && (_selectedLang == _langsList[0])
        && (_categoryList.indexOf(_selectedCategory) != 0)){
        await _getAllCatProjects(_selectedCategory);
    }

    if (isSwitched){
      _getAllAvailableProjects();
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

  _showHideButtons () async{
    return showButtons = await checkStudentExist(globals.userId);
  }
}
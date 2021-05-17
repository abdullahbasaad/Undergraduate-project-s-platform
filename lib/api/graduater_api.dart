// All required packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduater/models/programming_languages.dart';
import 'package:graduater/models/projects.dart';
import 'package:graduater/models/skills.dart';
import 'package:graduater/models/staff.dart';
import 'package:graduater/models/user.dart';
import 'package:graduater/notifier/auth_notifier.dart';
import 'package:graduater/models/globals.dart' as globals;
import 'package:rflutter_alert/rflutter_alert.dart';

// Login function, check database (Firebase) authentication, ckeck a user profile, check application authentication
login(User user, AuthNotifier authNotifier,BuildContext context) async {
  AuthResult authResult = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: user.email, password: user.password)
      // ignore: return_of_invalid_type_from_catch_error
      .catchError((error) =>  Alert(
                          context: context,
                          title: "Error!!",
                          desc: error.code,
                          image: Image.asset("images/fail.png"),
                        ).show());

  if (authResult.user != null) {
    globals.email = user.email;
    FirebaseUser firebaseUser = authResult.user;

    if (firebaseUser != null) {
      authNotifier.setUser(firebaseUser);
      globals.email = firebaseUser.email;

      QuerySnapshot querySnapshot = await getDocuemntId(user.email.toLowerCase());

      if (querySnapshot.documents.length > 0){
        if (querySnapshot.documents[0].data['admin'])
          Navigator.pushNamed(context, '/adminMenu');
        else
          Navigator.pushNamed(context, '/showProjects');

        globals.userId = querySnapshot.documents[0].data['userId'];
        globals.admin = querySnapshot.documents[0].data['admin'];
      }else{
        Alert(
          context: context,
          title: "Erorr!",
          desc: "No privileg to login to the system, please contact the admin",
          image: Image.asset("images/fail.png"),
        ).show();
      }
    }
  }
}

// Get all document information for a particular document
Future<DocumentSnapshot> getProjectDoc(String projDoc) async{
  DocumentSnapshot ds = await Firestore.instance.collection('project').document(projDoc).get();
  return ds;
}

// Get user name for a specific user
Future<String> getUserName(int usrId) async{
  QuerySnapshot qShot = await getUserDocument(usrId);
  if (qShot.documents.length > 0)
    return qShot.documents[0].data['userName'];
  else
    return null;
}

// Get all documents for a specific user from user's collection
Future<QuerySnapshot> returnStudentAssignedId(String projId) async{
  return Firestore.instance.collection('student').where('projectId', isEqualTo: projId)
      .getDocuments();
}

// Get a student assigned to (id - name)
Future<String> getStudentAssignedName(String projId) async{
  int stdId;
  String stdName;
  QuerySnapshot qShot = await returnStudentAssignedId(projId);
  if (qShot.documents.length > 0) {
    stdId = qShot.documents[0].data['studentId'];
    stdName = await getUserName(stdId);
    return stdId.toString()+' - '+stdName;
  }else
    return null;
}


// Get all documents for a specific user from user's collection
Future<QuerySnapshot> getUserDocument(int usrId) async{
  return Firestore.instance.collection('user').where('userId', isEqualTo: usrId)
      .getDocuments();
}

// Get document information from user colection for a specific user email
Future<QuerySnapshot> getUserDocumentByEmail(String email) async{
  return Firestore.instance.collection('user').where('email', isEqualTo: email)
      .getDocuments();
}

// Get a student course name
Future<String> getStudentCourse(String email) async{
  int usrId;
  QuerySnapshot qShot = await getUserDocumentByEmail(email);
  if (qShot.documents.length > 0)
    usrId = qShot.documents[0].data['userId'];

  if (usrId != null){
    QuerySnapshot qShot = await hasStudentProject(usrId);
    if (qShot.documents.length > 0)
      return qShot.documents[0].data['course'];
  }
  return null;
}

// Get a user name from getUserDocumentByEmail function where email equal given email
Future<String> getUserNameFromEmail(String email) async{
  QuerySnapshot qShot = await getUserDocumentByEmail(email);
  if (qShot.documents.length > 0)
    return qShot.documents[0].data['userName'];
  else
    return null;
}

// Return a document id from user's collection where email equal a given email
Future<QuerySnapshot> getDocuemntId(String email) async{
    return Firestore.instance.collection('user').where('email', isEqualTo: email)
    .getDocuments();
}

// Return all documents for a project's collection
Future<QuerySnapshot> getProjectDocuments() {
  return Firestore.instance.collection('project').getDocuments();
}

// Return all documents for a project's collection
Future<QuerySnapshot> getProjectSupervisorDocuments(String sprName) {
  return Firestore.instance.collection('project').where('supervisorName', isEqualTo: sprName).getDocuments();
}

// Return all available projects collection
Future<QuerySnapshot> getProjectAvailableDocuments(bool avlbl) {
  return Firestore.instance.collection('project').where('available', isEqualTo: avlbl).getDocuments();
}

// Return all documents for a skill's collection
Future<QuerySnapshot> getSkillDocuments() {
  return Firestore.instance.collection('skill').getDocuments();
}

// Return all documents for a programming languages's collection
Future<QuerySnapshot> getProgDocuments() {
  return Firestore.instance.collection('programmingLanguages').getDocuments();
}

// To check if a prgramming language inserted to a specific project or not?
Future<bool> checkProgProjectDocuments(String projDoc, String langDesc) async  {
  QuerySnapshot qShot = await Firestore.instance.collection('projectLanguages').where('projDocument', isEqualTo: projDoc )
  .where('langDesc', isEqualTo: langDesc).getDocuments();

  if (qShot.documents.length > 0)
    return true;
  else
    return false;
}

// To check if a student assigned project or not?
Future<bool> isStudentHasProject(int stdId) async {
  QuerySnapshot qShot = await hasStudentProject(stdId);
  if (qShot.documents.length > 0) {
    if (qShot.documents[0].data['projectId'] != null)
      return false;
  }
  return true;
}

// Return a project id of student if a student has a project
Future<String> returnStudentProject(int stdId) async {
  QuerySnapshot qShot = await hasStudentProject(stdId);
  if (qShot.documents.length > 0)
    return qShot.documents[0].data['projectId'];
  else
    return null;
}

// Check if student id exists in the student's collection
Future<bool> checkStudentExist(int stdId) async {
  QuerySnapshot qShot = await getStudentDocuments(stdId);

  if (qShot.documents.length > 0)
    return true;
  else
    return false;
}

// Check if student id exists in the student's collection
Future<bool> checkProjectSelected(String prj) async {
  QuerySnapshot qShot = await Firestore.instance.collection('student').where('projectId', isEqualTo: prj).getDocuments();

  if (qShot.documents.length > 0)
    return true;
  else
    return false;
}

// Check if a particular skill exists in a specific project or not?
Future<bool> checkSkillProjectDocuments(String projDoc, String skillDoc) async  {
  QuerySnapshot qShot = await Firestore.instance.collection('projectSkills').where('projDocument', isEqualTo: projDoc )
      .where('skillDesc', isEqualTo: skillDoc).getDocuments();

  if (qShot.documents.length > 0)
    return true;
  else
    return false;
}

// Return all projects ids with a specific skill
Future<QuerySnapshot> returnProjectsWithSpecifcSkill(String skillDsc) async {
  return Firestore.instance.collection('projectSkills')
      .where('skillDesc', isEqualTo: skillDsc)
      .getDocuments();
}

// Return all projects ids with a specific programming language
Future<QuerySnapshot> returnProjectsWithSpecifcLang(String langDesc) async {
  return Firestore.instance.collection('projectLanguages')
      .where('langDesc', isEqualTo: langDesc)
      .getDocuments();
}

// Return a project object where a specific skill includes
Future<Projects> returnProjectSkillQueryDocuments(String docId) async {
  DocumentSnapshot skillDoc = await Firestore.instance.collection('projectSkills').document(docId).get();
  //if (skillDoc.data.length > 0) {
    String projectDocument = skillDoc.data['projDocument'];
    DocumentSnapshot projDoc = await Firestore.instance.collection('project')
        .document(projectDocument)
        .get();

    if (projDoc.data.length > 0)
      return Projects(
          projDoc.documentID,
          projDoc.data['projectTitle'],
          projDoc.data['projectDesc'],
          projDoc.data['proposedBy'],
          projDoc.data['supervisor'],
          projDoc.data['noOfStudents'],
          projDoc.data['supervisorName'],
          projDoc.data['available']
      );
    else
      return null;
}

// Return a project object where a specific programming language includes
Future<Projects> returnProjectLangQueryDocuments(String docId) async {
  DocumentSnapshot langDoc = await Firestore.instance.collection('projectLanguages').document(docId).get();
  String projectDocument = langDoc.data['projDocument'];
  DocumentSnapshot projDoc = await Firestore.instance.collection('project')
      .document(projectDocument)
      .get();

  if (projDoc.data.length > 0){
    return Projects(
        projDoc.documentID,
        projDoc.data['projectTitle'],
        projDoc.data['projectDesc'],
        projDoc.data['proposedBy'],
        projDoc.data['supervisor'],
        projDoc.data['noOfStudents'],
        projDoc.data['supervisorName'],
        projDoc.data['available']);}
  else
    return null;
}

// Get all documents from project language's collection where a project id equal a given projec id
Future<QuerySnapshot> getLangProjectDocuments(String projDoc) async  {
   return await Firestore.instance.collection('projectLanguages').where('projDocument', isEqualTo: projDoc )
      .getDocuments();
}

// Get all documents from project skill's collection where a project id equal a given projec id
Future<QuerySnapshot> getSkillProjectDocuments(String projDoc) async  {
  return await Firestore.instance.collection('projectSkills').where('projDocument', isEqualTo: projDoc )
      .getDocuments();
}

// Return skills as a list
Future<List<Skills>> getSkillList() async {
  QuerySnapshot qShot = await getSkillDocuments();

  return qShot.documents.map(
          (doc) => Skills(
          doc.documentID,
          doc.data["skillDesc"])
  ).toList();
}

// Return all documents for a staff collection
Future<QuerySnapshot> getStaffDocuments() async {
  return await Firestore.instance.collection('staff').getDocuments();
}

// Return programming languages as a list
Future<List<ProgrammingLanguages>> getProgList() async {
  QuerySnapshot qShot = await getProgDocuments();

  return qShot.documents.map(
          (doc) => ProgrammingLanguages(
          doc.documentID,
          doc.data["langDesc"])
  ).toList();
}

// Get all documents from project skill's collection where project document equal a specific document
Future<QuerySnapshot> getProjectSkills(String projDoc) async{
  return Firestore.instance.collection('projectSkills').where('projDocument', isEqualTo: projDoc)
      .getDocuments();
}

// Get a document id from skills collection where desc equal a given skill description
Future<String> getSkillDesc(String skillDoc) async{
  return Firestore.instance.collection('skills').document(skillDoc).documentID;
}

// Return a language description for all documents
Future<String> getLangDesc() async{
  QuerySnapshot qSnap = await Firestore.instance.collection('programmingLanguages').getDocuments();
}

// Get all documents from project languages's collection where project docuemnt equlas a given project document
Future<QuerySnapshot> getProjectLangs(String projDoc) async{
  return Firestore.instance.collection('projectLanguages').where('projDocument', isEqualTo: projDoc)
      .getDocuments();
}

// Return how many student already assigned to a specific project
Future<int> getHowManyStudentAssigned(String projDoc) async{
  QuerySnapshot qSnap = await Firestore.instance.collection('student').where('projectId', isEqualTo: projDoc)
      .getDocuments();
  return qSnap.documents.length;
}

// Get all documents from student's collection where student id equals a given student id
Future<QuerySnapshot> getStudentDocuments(int stdId) async{
  return Firestore.instance.collection('student').where('studentId', isEqualTo: stdId)
      .getDocuments();
}

// Check if a specific student id has a project or not?
Future<QuerySnapshot> hasStudentProject(int stdId) async{
  return Firestore.instance.collection('student').where('studentId', isEqualTo: stdId)
      .getDocuments();
}

// Add new user profile into the database and user collection, to give him/her the both authentication
register (User user, AuthNotifier authNotifier) async {
  AuthResult authResult = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: user.email, password: user.password)
      .catchError((error) => print(error.code));

      if (authResult.user.uid != null) {
        UserUpdateInfo updateInfo = UserUpdateInfo();
        updateInfo.displayName = user.userName;

        FirebaseUser firebaseUser = authResult.user;

        if (firebaseUser != null) {
          firebaseUser.updateProfile(updateInfo);

          await firebaseUser.reload();

          print("Sign up $firebaseUser");

          FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
          authNotifier.setUser(currentUser);

          Firestore.instance.collection("user").document().setData({
            'admin': false,
            'password': user.password,
            'userId': user.userId,
            'userName': user.userName,
            'email': user.email});
        }
      }
}

// Sign out function
signOut(AuthNotifier authNotifier) async {
  await FirebaseAuth.instance.signOut().catchError((error) => print(error.code));
  globals.email = null;
  authNotifier.setUser(null);
}

// Initialize the current user
initializeCurrentUser(AuthNotifier authNotifier) async {
  FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();

  if (firebaseUser != null){
    authNotifier.setUser(firebaseUser);
  }
}

// Add new skill into the system
addNewSkill(int docId, String skillDesc) async{
  await Firestore.instance.collection("skill").document().setData({
    'docId':(docId+1).toString(),
    'skillDesc': skillDesc,
    'createdDt': DateTime.now()});
}

Future<bool> checkSkillExist(String skl) async  {
  QuerySnapshot qShot = await Firestore.instance.collection('skill').where('skillDesc', isEqualTo: skl )
      .getDocuments();

  if (qShot.documents.length > 0)
    return true;
  else
    return false;
}
//////////////////////////////////////////////////////////////////////////////////////
Future<bool> checkLangExist(String lng) async  {
  QuerySnapshot qShot = await Firestore.instance.collection('projectLanguages').where('langDesc', isEqualTo: lng )
      .getDocuments();

  if (qShot.documents.length > 0)
    return true;
  else
    return false;
}

// Add new skill into the system
addNewSkillNId(String skillDesc) async{
  await Firestore.instance.collection("skill").document().setData({
    'skillDesc': skillDesc,
    'createdDt': DateTime.now()});
}

// Add new languages
addNewLangNId(String langDesc) async{
  await Firestore.instance.collection("programmingLanguages").document().setData({
    'langDesc': langDesc,
    'createdDt': DateTime.now()});
}

// Add new programming language into the system
addProjectLang(String projDoc, String langDoc) async{
  await Firestore.instance.collection("projectLanguages").document().setData({
    'langDesc': langDoc,
    'projDocument': projDoc,
    'createdDt': DateTime.now()});
}

// Add a skill into a specific project
addProjectSkill(String projDoc, String skillDesc) async{
  await Firestore.instance.collection("projectSkills").document().setData({
    'skillDesc': skillDesc,
    'projDocument': projDoc,
    'createdDt': DateTime.now()});
}

// Add a new project into the system -- manual
addProject(Projects prj, String docId) async{
  if (docId != null)
    await Firestore.instance.collection("project").document(docId).setData({
      'noOfStudents': prj.noOfStudents,
      'projectDesc': prj.projectDesc,
      'projectTitle': prj.projectTitle,
      'proposedBy': prj.proposedBy,
      'supervisor': prj.supervisor,
      'supervisorName' : prj.supervisorName,
      'available' : prj.available,
      'createdDt': DateTime.now()});
  else
    Firestore.instance.collection("project").document()
      .setData({
      'noOfStudents': prj.noOfStudents,
      'projectDesc': prj.projectDesc,
      'projectTitle': prj.projectTitle,
      'proposedBy': prj.proposedBy,
      'supervisor': prj.supervisor,
      'createdDt': DateTime.now()});
}

// Update a project information
Future<void> updateProjectDocument (Projects prj, String doc) async{
  await Firestore.instance
          .collection('project')
          .document(doc)
          .updateData({
            'noOfStudents': prj.noOfStudents,
            'projectDesc': prj.projectDesc,
            'projectTitle': prj.projectTitle,
            'proposedBy': prj.proposedBy,
            'supervisor': prj.supervisor
          });
}

// Update a skill information
updateSkill(String docId, String skillDesc) async{
  await Firestore.instance
      .collection('skill')
      .document(docId)
      .updateData({'skillDesc': skillDesc});
}

// Grant a normal user the Admin's role
Future<bool> updateUserPrivilege(String email) async{
  QuerySnapshot  qs = await Firestore.instance.collection('user')
      .where('email', isEqualTo: email)
      .getDocuments();

  if (qs.documents.length > 0) {
    String docId = qs.documents[0].documentID.toString();
    await Firestore.instance.collection('user')
        .document(docId)
        .updateData({'admin': true});
    return true;
  }
  else
    return false;
}

// Check if the email exists or not?
Future<bool> checkEmailAddress(String email) async{
  QuerySnapshot  qs = await Firestore.instance.collection('user')
      .where('email', isEqualTo: email)
      .getDocuments();

  if (qs.documents.length > 0) return true;
  return false;
}

// Check if the userId exists or not?
Future<bool> checkUserExistById(int usrId) async{
  QuerySnapshot  qs = await Firestore.instance.collection('user')
      .where('userId', isEqualTo: usrId)
      .getDocuments();

  if (qs.documents.length > 0) return true;
  return false;
}

// Unassigned project from a particular student.
Future<bool> unsignStudentProject(int stdtId) async{
  QuerySnapshot  qs = await Firestore.instance.collection('student')
      .where('studentId', isEqualTo: stdtId)
      .getDocuments();

  if (qs.documents.length > 0) {
    String docId = qs.documents[0].documentID.toString();
    String projId = qs.documents[0].data['projectId'];
    await Firestore.instance.collection('student')
        .document(docId)
        .updateData({'projectId': null});
    await updateProjectAvailable(projId, true);
    return true;
  }
  else
    return false;
}

// Return docuemnts from student's collection for a specific student
Future<QuerySnapshot> getStudentDocument(int stdId) async{
  return Firestore.instance.collection('student').where('studentId', isEqualTo: stdId)
      .getDocuments();
}

// Update student document by assigning project id
assignProjectToStudent(int stdId, String projId) async{
  String stdDoc;
  QuerySnapshot qs = await getStudentDocument(stdId);
  if (qs.documents.length > 0){
    stdDoc = qs.documents[0].documentID;

    await Firestore.instance
        .collection('student')
        .document(stdDoc)
        .updateData({'projectId': projId});
  }
}

// Check if a staff exists or not
Future<bool> checkStaffDocument(int stfId) async{
  QuerySnapshot qs = await Firestore.instance.collection('staff').where('staffId', isEqualTo: stfId)
      .getDocuments();

  if (qs.documents.length > 0) return true;
  return false;
}

// Add new language into the system
addNewLang(int docId, String langDesc) async{
  await Firestore.instance.collection("programmingLanguages").document().setData({
    'docId':(docId+1).toString(),
    'langDesc': langDesc,
    'createdDt': DateTime.now()});

}

// Update programming language info for a specific document
updateLang(String docId, String langDesc) async{
  await Firestore.instance
      .collection('programmingLanguages')
      .document(docId)
      .updateData({'langDesc': langDesc});
}

// Update programming language info for a specific document
updateProjectAvailable(String docId, bool isAvailable) async{
  await Firestore.instance
      .collection('project')
      .document(docId)
      .updateData({'available': isAvailable});
}

// Clean the database
refreshGraduateDB () {
  Firestore.instance.collection('project').getDocuments().then((snapshot) {
    for (DocumentSnapshot ds in snapshot.documents) {
      ds.reference.delete();
    }
  });

  Firestore.instance.collection('staff').getDocuments().then((snapshot) {
    for (DocumentSnapshot ds in snapshot.documents) {
      ds.reference.delete();
    }
  });

  Firestore.instance.collection('student').getDocuments().then((snapshot) {
    for (DocumentSnapshot ds in snapshot.documents) {
      ds.reference.delete();
    }
  });

  Firestore.instance.collection('user').getDocuments().then((snapshot) {
    for (DocumentSnapshot ds in snapshot.documents) {
      ds.reference.delete();
    }
  });
}

// Add new chat room
addNewRoom(String docId, String sender, receiver) async{
  if (docId != null)
    await Firestore.instance.collection("rooms").document(docId).setData({
    'createdBy': sender,
    'sender' : sender,
    'receiver' : receiver,
    'createdAt': DateTime.now()});
}

// Add new message
addNewMessage(String message, String room, String sender, String receiver) async{
  await Firestore.instance.collection('messages').add({
    'room': room,
    'text' : message,
    'sender' : globals.email,
    'receiver' : receiver,
    'createdAt': DateTime.now()});
}

// get all messages for a specific room
getMessagesStream (String room) async{
  await for (var snapshot in Firestore.instance.collection('messages').where('room', isEqualTo: room).snapshots()){
    for (var message in snapshot.documents){
      return message.data['text'];
    }
  }
}

// get all messages for all rooms for a sender
getAllUserRoomsAsSender(String userEmail) async{
    return await Firestore.instance.collection('rooms')
        .where('sender', isEqualTo: userEmail)
        .getDocuments();
}

// get all messages for all rooms for a receiver
getAllUserRoomsAsReceiver(String userEmail) async{
  return await Firestore.instance.collection('rooms')
      .where('receiver', isEqualTo: userEmail)
      .getDocuments();
}

// Check if a new room is already opened or not?
Future<String> checkRoomExists(String sender, String receiver) async{
  String roomDoc;
  var result1 = await Firestore.instance.collection('rooms').where('sender', isEqualTo: sender)
      .where('receiver', isEqualTo: receiver)
      .getDocuments();

  var result2 = await Firestore.instance.collection('rooms').where('sender', isEqualTo: receiver)
      .where('receiver', isEqualTo: sender)
      .getDocuments();

  if (result1.documents.length > 0){
    roomDoc = result1.documents[0].documentID;
  }

  if (result2.documents.length > 0){
    roomDoc = result2.documents[0].documentID;
  }
  return roomDoc??null;
}

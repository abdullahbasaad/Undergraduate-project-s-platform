import 'package:flutter/material.dart';
import 'package:graduater/notifier/auth_notifier.dart';
import 'package:graduater/screens/addLanguages.dart';
import 'package:graduater/screens/addNewProject.dart';
import 'package:graduater/screens/addProjectLang.dart';
import 'package:graduater/screens/addProjectSkills.dart';
import 'package:graduater/screens/addSkills.dart';
import 'package:graduater/screens/adminMenu.dart';
import 'package:graduater/screens/chat.dart';
import 'package:graduater/screens/confirmEmail.dart';
import 'package:graduater/screens/forgotPassword.dart';
import 'package:graduater/screens/login.dart';
import 'package:graduater/screens/showRooms.dart';
import 'package:graduater/screens/register.dart';
import 'package:graduater/screens/showProjects.dart';
import 'package:graduater/screens/uploadProjects.dart';
import 'package:graduater/screens/uploadStaffInfrmation.dart';
import 'package:graduater/screens/uploadStudentInformation.dart';
import 'package:provider/provider.dart';


void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => AuthNotifier(),
      )
    ],
    child: Graduater(),
  ),
);

class Graduater extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Graduater',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.lightBlue,
      ),
      initialRoute: '/',
      routes: {
        '/register': (context) => Register(),
        '/addSkills': (context) => AddSkills(),
        '/addLang': (context) => AddLanguages(),
        '/showProjects': (context) => ShowProjects(),
        '/addNewProject': (context) => AddNewProject(),
        '/uploadProjects': (context) => UploadProjects(),
        '/adminMenu': (context) => AdminMenu(),
        '/uploadStudentsInfo': (context) => UploadStudentInfo(),
        '/uploadStaffInfo': (context) => UploadStaffInformation(),
        '/addProjectSkills': (context) => AddProjectSkills(),
        '/addProjectLangs': (context) => AddProjectLangs(),
        '/showRooms': (context) => ShowRooms(),
        '/chat': (context) => Chat(),
        ConfirmEmail.id: (context) => ConfirmEmail(),
        ForgotPassword.id: (context) => ForgotPassword(),

        // '/test': (context) => Testy(),
      },
      home: Consumer<AuthNotifier>(
        builder: (context, notifier, child) {
          return Login();
          //return notifier.user != null ? Register() : Login();

          //notifier.user != null ? Login() : Register();
        },
      ),
    );
  }
}

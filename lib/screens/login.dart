import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduater/api/graduater_api.dart';
import 'package:graduater/notifier/auth_notifier.dart';
import 'package:graduater/models/user.dart';
import 'package:graduater/models/globals.dart' as globals;
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../constant.dart';
import 'forgotPassword.dart';
import 'package:connectivity/connectivity.dart';

enum AuthMode { Register, Login }

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _ctrlUserEmail = TextEditingController();
  final _ctrlUserPassword = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  AuthMode _authMode = AuthMode.Login;

  User _user = User();

  // This Function for initiating the page
  @override
  void initState() {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    initializeCurrentUser(authNotifier);
    super.initState();
    _ctrlUserEmail.text = 'abd_bas@hotmail.com';
    _ctrlUserPassword.text = 'ab123456';
  }

  // This Function to check user authentication
  void _submitForm() async{
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(
        context, listen: false);

    if (await _checkConnectivity()) {
      if (_authMode == AuthMode.Login) {
        login(_user, authNotifier, context);
      } else {
        register(_user, authNotifier);
      }
    }else{
      Alert(
        context: context,
        title: "Error!!",
        desc: "No signal, please check the internet connection!..",
        image: Image.asset("images/fail.png"),
      ).show();
    }
  }

  // This Function to build different components in the page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          constraints: BoxConstraints.expand(),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 150.0),
                  Container(
                    height: 200.0,
                    margin: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                          height: 50.0,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
                          child: TextFormField(
                              controller: _ctrlUserEmail,
                              textInputAction: TextInputAction.next,
                              onEditingComplete: () {
                                FocusScope.of(context).nextFocus();
                              },
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Email is required';
                                }

                                if (!RegExp(
                                    r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }

                                return null;
                              },
                              onSaved: (String value) {
                                _user.email = value.toLowerCase();
                              },
                              style: kTextFieldStyle,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  color: Colors.blueGrey,
                                ),
                                hintText: 'Enter your email',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            height: 50.0,
                            margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
                            child: TextFormField(
                              controller: _ctrlUserPassword,
                              obscureText: true,
                              style: kTextFieldStyle,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  color: Colors.blueGrey,
                                ),
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                prefixIcon: const Icon(
                                  Icons.vpn_key,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Password is required';
                                }

                                if (value.length < 5 || value.length > 20) {
                                  return 'Password must be betweem 5 and 20 characters';
                                }

                                return null;
                              },
                              onSaved: (String value) {
                                _user.password = value;
                              },
                            ),
                          ),
                          SizedBox(height: 5.0),
                        ],
                      )
                    ),
                  ),
                  Container(
                    height: 40.0,
                    margin: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      shadowColor: Colors.blueGrey,
                      color: Colors.blue,
                      child: GestureDetector(
                        onTap: () {
                          _submitForm();
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(duration: new Duration(seconds: 5), content:
                            Row(
                              children: <Widget>[
                                new CircularProgressIndicator(),
                                new Text(" Uploading ...")
                              ],
                            ),
                            ));
                        },
                        child: Center(
                          child: Text(
                            'LOGIN',
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
                  Container(
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New to BCU ?',
                            style: TextStyle(fontFamily: 'Montserrat'),
                          ),
                          SizedBox(width: 5.0),
                          InkWell(
                            onTap: () {
                              _ctrlUserEmail.text = '';
                              _ctrlUserPassword.text = '';
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text('Sign up',
                              style: TextStyle(fontFamily: 'Montserrat',
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                          SizedBox(width: 30.0,),
                          FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                ForgotPassword.id,
                              );
                            },
                            child: Text(
                              'FORGOT PASSWORD?',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // This Function to check the internet connection
  Future<bool> _checkConnectivity() async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if ((connectivityResult == ConnectivityResult.mobile) || (connectivityResult == ConnectivityResult.wifi))
      return true;
    else
      return false;
  }
}

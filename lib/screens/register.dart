import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduater/api/graduater_api.dart';
import 'package:graduater/components/screenTitleWidget.dart';
import 'package:graduater/constant.dart';
import 'package:graduater/models/user.dart';
import 'package:graduater/notifier/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:graduater/models/globals.dart' as globals;

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  User _user = User();

  @override
  void initState(){
    super.initState();
    setState(() {
    });
    print(globals.email);
  }

  //TextController to read text entered in text field
  final _ctrlPassword = TextEditingController();
  final _ctrlConfirmPassword = TextEditingController();
  String title = 'Sign up';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: ScreenTitleWidget(screenTitle: 'Sign up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: null,
                ),
                SizedBox(height: 30.0),
                Container(
                  height: 50.0,
                  margin: EdgeInsets.fromLTRB(30.0,0.0,30.0,20.0),
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      FocusScope.of(context).nextFocus();
                    },
                    style: kTextFormFieldStyleRegistration,
                    decoration: InputDecoration(
                      hintText: 'USERNAME',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.blueAccent,
                      ),
                    ),
                    onChanged: (val) => setState(() => _user.userName = val),
                    validator: (val) => (val.length==0? 'Field must be entered': null),
                  ),
                ),
                SizedBox(height: 1.0),
                Container(
                  height: 50.0,
                  margin: EdgeInsets.fromLTRB(30.0,0.0,30.0,20.0),
                  child: TextFormField(
                    style: kTextFormFieldStyleRegistration,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      FocusScope.of(context).nextFocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'EMAIL',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.blueAccent,
                      ),
                    ),
                    onChanged: (val) => setState(() => _user.email = val.toLowerCase()),
                    validator: (String value){
                      if(value.isEmpty)
                      {
                        return 'Please a Enter';
                      }
                      if (!RegExp(
                          r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 1.0),
                Container(
                  height: 50.0,
                  margin: EdgeInsets.fromLTRB(30.0,0.0,30.0,20.0),
                  child: TextFormField(
                    inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                    style: kTextFormFieldStyleRegistration,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      FocusScope.of(context).nextFocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'USER ID',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(
                        Icons.confirmation_number,
                        color: Colors.blueAccent,
                      ),
                    ),
                    onChanged: (val) => setState(() => _user.userId = int.parse(val)),
                    validator: (val) => (val.length==0? 'Invalid user id':null),
                  ),
                ),
                SizedBox(height: 1.0),
                Container(
                  height: 50.0,
                  margin: EdgeInsets.fromLTRB(30.0,0.0,30.0,20.0),
                  child: TextFormField(
                    controller: _ctrlPassword,
                    obscureText: true,
                    style: kTextFormFieldStyleRegistration,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      FocusScope.of(context).nextFocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'PASSWORD',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(
                        Icons.vpn_lock,
                        color: Colors.blueAccent,
                      ),
                    ),
                    onChanged: (val) => setState(() => _user.password = val),
                    validator: (val) => (val.length<=5? 'Invalid password. length should be 5 or more!':null),
                  ),
                ),
                SizedBox(height: 1.0),
                Container(
                  height: 50.0,
                  margin: EdgeInsets.fromLTRB(30.0,0.0,30.0,20.0),
                  child:  TextFormField(
                    controller: _ctrlConfirmPassword,
                    obscureText: true,
                    style: kTextFormFieldStyleRegistration,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      FocusScope.of(context).nextFocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'CONFIRM PASSWORD',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(
                        Icons.vpn_lock,
                        color: Colors.blueAccent,
                      ),
                    ),
                    onChanged: (val) => setState(() => _user.password = val),
                    validator: (String value){
                      if(value.isEmpty)
                      {
                        return 'Please re-enter password';
                      }
                      if(_ctrlPassword.text!=_ctrlConfirmPassword.text){
                        return "Password does not match";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 30.0),
                Container(
                  child: ButtonTheme(
                    minWidth: 300.0,
                    height: 40.0,
                    child: RaisedButton(
                      onPressed: () {
                        _onSubmit();
                      },
                      child: const Text('Submit', style: TextStyle(fontSize: 18, color: Colors.white)),
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }

  _resetForm(){
    _formKey.currentState.reset();
    _ctrlConfirmPassword.clear();
    _ctrlPassword.clear();
  }

  _onSubmit() async{
    try {
      var form = _formKey.currentState;
      if (form.validate()) {
        form.save();
        AuthNotifier authNotifier = Provider.of<AuthNotifier>(
            context, listen: false);
        register(_user, authNotifier);
        _resetForm();

        Alert(
          context: context,
          title: "Success!",
          desc: "User has been inserted",
          image: Image.asset("images/success.png"),
        ).show();
      }
    }catch(e){
      print(e);
      Alert(
        context: context,
        title: "Erorr!",
        desc: "USER ID is already duplicated!..",
        image: Image.asset("images/fail.png"),
      ).show();
    }
  }
}
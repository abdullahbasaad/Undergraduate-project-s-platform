import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const kBottomContainerHeight = 80.0;
const kActiveCardColour = Color(0xFF1D1E33);
const kInactiveCardColour = Color(0xFF111328);
const kBottomContainerColour = Color(0xFFEB1555);

final themeColor = Color(0xfff5a623);
final primaryColor = Color(0xff203152);
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);

const kTextFieldStyle = TextStyle(
  fontSize: 18.0,
  color: Colors.black,
);

const kPrimaryColor = const Color(0xFFE3F2FD);
const kScaffoldColor = const Color(0xFFE3F2FD);

const kTextFormFieldStyleRegistration = TextStyle(
  fontSize:18.0,
  color: Colors.black,
  //fontWeight: FontWeight.bold,
  fontFamily: 'calibri',
);

const kTextFormFieldStyleAddProject = TextStyle(
  fontSize:15.0,
  color: Colors.black,
  //fontWeight: FontWeight.bold,
  fontFamily: 'calibri',
);

const kLabelTextStyle = TextStyle(
  fontSize: 18.0,
  color: Colors.white,
);

const kLargeButtonTextStyle = TextStyle(
  fontSize: 25.0,
  fontWeight: FontWeight.bold,
);

const kTitleTextStyle = TextStyle(
  fontSize: 50.0,
  fontWeight: FontWeight.bold,
);

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
  color: Colors.white,
);

final kSpinkit = SpinKitFadingCircle(
  itemBuilder: (BuildContext context, int index) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.red : Colors.green,
      ),
    );
  },
);
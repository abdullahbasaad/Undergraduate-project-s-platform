import 'package:flutter/material.dart';

class ScreenTitleWidget extends StatelessWidget {

  final String screenTitle;
  ScreenTitleWidget({@required this.screenTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(screenTitle,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Broadway',
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

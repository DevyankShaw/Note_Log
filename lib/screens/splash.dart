import 'dart:async';

import 'package:flutter/material.dart';
import 'package:note_log/screens/note_list.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 1),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => NoteList())));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Image.asset(
          'images/note_log.png',
          width: 100.0,
          height: 100.0,
        ),
      ),
    );
  }
}

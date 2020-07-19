import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  static String id = 'setting_screen';

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Setting'),
      )
    );
  }
}

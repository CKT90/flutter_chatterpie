import 'package:flutter/material.dart';

import '../screens/tab_setting_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/chat_index.dart';
import '../screens/chat_screen.dart';


class MaterialFirstPage extends StatelessWidget {

  MaterialFirstPage({this.selectedPage});

  final String selectedPage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: selectedPage,
        theme: ThemeData(
          primaryColor: Color(0xff075E54),
          accentColor: Color(0xff25D366),
        ),
        routes: {
          ChatIndexScreen.id: (context) => ChatIndexScreen(),
          SettingScreen.id: (context) => SettingScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          WelcomeScreen.id: (context) => WelcomeScreen(),
          RegistrationScreen.id: (context) => RegistrationScreen(),
        }
    );
  }
}

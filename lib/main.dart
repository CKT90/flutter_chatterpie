import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'components/MaterialFirstPage.dart';

import 'screens/login_screen.dart';
import 'screens/chat_index.dart';



void main() => runApp(LoadPage());

class LoadPage extends StatefulWidget {
  @override
  _LoadPageState createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  Future checkIfLoggedIn;

  @override
  void initState() {
    super.initState();
    checkIfLoggedIn = FirebaseAuth.instance.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: checkIfLoggedIn,
        builder: (BuildContext context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent,
                ),
              );
            default:
              if (snapshot.data == null)
                return MaterialFirstPage(
                  selectedPage: LoginScreen.id,
                );
              else
                return MaterialFirstPage(
                  selectedPage: ChatIndexScreen.id,
                );
          }
        });
  }
}

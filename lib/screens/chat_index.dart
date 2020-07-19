import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screens/tab_chat_list_screen.dart';
import '../screens/tab_setting_screen.dart';
import '../screens/login_screen.dart';

class ChatIndexScreen extends StatefulWidget {
  static String id = 'chat_index';

  @override
  _ChatIndexScreenState createState() => _ChatIndexScreenState();
}

class _ChatIndexScreenState extends State<ChatIndexScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  Future<Null> openDialog() async {
    return showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Exit app?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Exit"),
                onPressed: () {
                  exit(0);
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 0, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatty'),
        elevation: 0.7,
        bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(text: 'CHATS'),
              Tab(text: 'SETTINGS'),
            ]),
        actions: <Widget>[
          Icon(Icons.search),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: PopupMenuButton<int>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Text("option 1"),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text("Sign Out"),
                ),
              ],
              child: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 2) {
                  setState(() {
                    FirebaseAuth.instance.signOut();
                    GoogleSignIn().signOut();
                    Navigator.pushReplacementNamed(context, LoginScreen.id);
                    Fluttertoast.showToast(msg: "signed out!");
                  });
                } else {
                  setState(() {
                    Fluttertoast.showToast(msg: "pressed option 1 button");
                  });
                }
              }
            ),
          ),
        ],
      ),
      body: WillPopScope(
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            ChatListScreen(),
            SettingScreen(),
          ],
        ),
        onWillPop: openDialog,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(
          Icons.message,
          color: Colors.white,
        ),
        onPressed: () {
          Fluttertoast.showToast(msg: "Floating action button pressed!");
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:io';

import '../screens/chat_index.dart';
import '../screens/registration_screen.dart';
import '../components/RoundedButton.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool showSpinner = false;
  String email;
  String password;
  FirebaseUser currentUser;

  Future<Null> handleGoogleSignIn() async {

    GoogleSignInAccount googleUser;

    try {
      googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        FirebaseUser firebaseUser =
            (await _auth.signInWithCredential(credential)).user;

        //prevent updated created_at details for each users
        final QuerySnapshot result = await Firestore.instance
            .collection('users')
            .where('id', isEqualTo: firebaseUser.uid)
            .getDocuments();

        final List<DocumentSnapshot> documents = result.documents;

        if (documents.length == 0) {
          //insert firebase failure
          Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .setData({
            'nickname': firebaseUser.displayName,
            'photoUrl': firebaseUser.photoUrl,
            'id': firebaseUser.uid,
            'email': firebaseUser.email,
            'createdAt': DateTime
                .now()
                .millisecondsSinceEpoch
                .toString(),
          });
        }
        //prevent updated created_at details for each users

        Fluttertoast.showToast(msg: "Signed in successfully!");
        Navigator.pushNamed(context, ChatIndexScreen.id);

      } else {
        //insert google user failure
      }
    } catch (error) {
      print(error);
      Fluttertoast.showToast(msg: "account has issue!");
    }
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: openDialog,
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 26.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset('assets/images/tehtarik.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.left,
                  onChanged: (value) async {
                    email = value;
                  },
                  decoration: InputDecoration(
                    hintText: "Email",
//                kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                    obscureText: true,
                    textAlign: TextAlign.left,
                    onChanged: (value) {
                      password = value;
                    },
                    decoration: InputDecoration(hintText: "Password")),
                SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                  title: 'Log In',
                  colourTop: Colors.lightBlueAccent,
                  colourBottom: Colors.blue,
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      final newUser = await _auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      if (newUser != null) {
                        Navigator.pushReplacementNamed(
                            context, ChatIndexScreen.id);
                        Fluttertoast.showToast(msg: "Logged in!");
                      }
                    } catch (error) {
                      setState(() {
                        showSpinner = false;
                      });
                      print(error.toString());
                      Fluttertoast.showToast(msg: "Information not valid!");
                    }
                  },
                ),
                RoundedButton(
                  title: 'Sign in with Google',
                  colourTop: Colors.redAccent,
                  colourBottom: Colors.redAccent[100],
                  onPressed: () async {
                    handleGoogleSignIn();
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Don't have an account ?",
                      style: TextStyle(color: Colors.grey),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, RegistrationScreen.id);
                      },
                      textColor: Colors.black87,
                      child: Text("Create Account"),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

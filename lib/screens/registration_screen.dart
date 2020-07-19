import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screens/chat_index.dart';
import '../components/RoundedButton.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;
  String uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 150.0,
                    child: Image.asset('assets/images/tehtarik.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 24.0,
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
                title: 'Register',
                colourTop: Colors.lightBlueAccent,
                colourBottom: Colors.blue,
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    if (newUser != null) {
                      FirebaseUser firebaseUser = newUser.user;
                      if (firebaseUser != null) {
                        final QuerySnapshot result = await Firestore.instance
                            .collection('users')
                            .where('id', isEqualTo: firebaseUser.uid)
                            .getDocuments();

                        final List<DocumentSnapshot> documents =
                            result.documents;

                        if (documents.length == 0) {
                          // Update data to server if new user
                          Firestore.instance
                              .collection('users')
                              .document(firebaseUser.uid)
                              .setData({
                            'nickname': firebaseUser.email,
                            'id': firebaseUser.uid,
                            'email': firebaseUser.email,
                            'createdAt': DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                          });
                        }
                        Navigator.pushNamed(context, ChatIndexScreen.id);
                      }
                    }
                  } catch (e) {
                    print(e);
                    setState(() {
                      showSpinner = false;
                    });
                    Fluttertoast.showToast(msg: "Information not complete!");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  FirebaseUser loggedInUser;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null && !snapshot.hasError) {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, int index) {
                if (snapshot.data.documents[index].data['email'] ==
                    loggedInUser.email) {
                  return Container();
                } else {
                  return Container(
                    margin:
                        EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
                    child: FlatButton(
                      color: Color(0xffE8E8E8),
                      padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () async {
                        List<String> groupChatId = [
                          loggedInUser.uid,
                          await snapshot.data.documents[index].data['id']
                        ];
                        //groupChatId.s;
                        print(groupChatId.toString());
                        final QuerySnapshot result = await Firestore.instance
                            .collection('chatGroupIds')
                            .where('id', isEqualTo: groupChatId.toString())
                            .getDocuments();

                        final List<DocumentSnapshot> documents =
                            result.documents;

                        if (documents.length == 0) {
                          Firestore.instance
                              .collection('chatGroupIds')
                              .document(groupChatId.toString())
                              .setData({
                            'id': groupChatId.toString(),
                          });
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              selectedEmail:
                                  snapshot.data.documents[index].data['email'],
                              currentEmail: loggedInUser.email,
                              groupChatId: groupChatId.toString(),
                            ),
                          ),
                        );
                      },
                      child: Row(children: <Widget>[
                        Material(
                          child: Container(
                            child: Image.asset('assets/images/inu.png'),
                            width: 100.0,
                            height: 100.0,
                            padding: EdgeInsets.all(15.0),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(left: 20.0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    snapshot
                                        .data.documents[index].data['nickname'],
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  margin:
                                      EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  );
                }
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
              ),
            );
          }
        },
      ),
    );
  }
}

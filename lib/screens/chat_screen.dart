import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants.dart';
import '../screens/login_screen.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  final String selectedEmail;
  final String currentEmail;
  final String groupChatId;

  ChatScreen({@required this.selectedEmail, @required this.currentEmail, @required this.groupChatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;
  FirebaseUser loggedInUser;
  ScrollController _scrollController = ScrollController();

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
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        actions: <Widget>[
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
        title: Text(widget.selectedEmail),
        backgroundColor: Color(0xff075E54),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(
              groupChatId: widget.groupChatId,
              currentUserEmail: widget.currentEmail,
              scrollController: _scrollController,
            ),
            Padding(
              padding: const EdgeInsets.only(left:8.0, right:8.0),
              child: Container(
                height: 80.0,
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        messageTextController.clear();
                        _firestore.collection('chatGroupIds')
                            .document(widget.groupChatId)
                            .collection('messages')
                            .add({
                          'text': messageText,
                          'sender': loggedInUser.email,
                          'recipient': widget.selectedEmail,
                          'timestamp' : DateTime.now(),
                        });
                        _scrollController.animateTo(
                          0.0,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Color(0xff075E54),
                        maxRadius: 30.0,
                        child: Icon(Icons.send, color: Colors.white,),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {

  final String groupChatId;
  final String currentUserEmail;
  final ScrollController scrollController;

  MessagesStream({@required this.groupChatId, @required this.currentUserEmail, @required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chatGroupIds').document(groupChatId).collection('messages').orderBy('timestamp').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];

          final currentUser = currentUserEmail;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            ownMessage: currentUser == messageSender,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            controller: scrollController,
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.ownMessage});

  final String sender;
  final String text;
  final bool ownMessage;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: ownMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: ownMessage ? BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
            ) :
            BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
            ),
            elevation: 2.0,
            color: ownMessage ? Color(0xffdcf8c6) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              child: Text(
                '$text',
                style: TextStyle(
                  color: ownMessage ? Colors.black87 : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

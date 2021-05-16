import 'package:flutter/material.dart';
import 'package:graduater/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduater/models/globals.dart' as globals;
import 'package:graduater/api/graduater_api.dart';
import 'package:graduater/screens/showRooms.dart';
import 'package:intl/intl.dart';


class Chat extends StatefulWidget {
  final room;
  final receiver;
  final sender;
  Chat({this.room, this.receiver, this.sender});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final messageTextController = TextEditingController();
  String messageText;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShowRooms()),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.insert_invitation),
              onPressed: () {
                //Implement logout functionality
              }),
        ],
        title: Row(
          children: [
            Icon(Icons.account_circle,
            size: 35.0,),
            SizedBox(width: 10.0,),
            Container(
              padding: EdgeInsets.only(bottom: 3.0),
              child:  FutureBuilder<String>(
                future: _returnReceiverName(widget.receiver==globals.email.toLowerCase()?widget.sender:widget.receiver),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),);
                  }else
                    return Container();
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
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
                  FlatButton(
                    onPressed: () async{
                      if (messageText != null) {
                        await addNewMessage(
                            messageText, widget.room, globals.email.toLowerCase(),
                            widget.receiver);
                        messageTextController.clear();
                        messageText = null;
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _returnReceiverName(String email) async {
    String name;
    name = await getUserNameFromEmail(email.toLowerCase());
    if (name!=null)
      return name;
    else
      return '?';
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('messages').where('room', isEqualTo: globals.roomDoc)
          .orderBy('createdAt').snapshots(),
      builder: (context, snapshot){
        List<MessageBubble> messageBubbles = [];
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,

            ),
          );
        }else{
          final messages = snapshot.data.documents.reversed;
          for (var message in messages) {
            final sender = message.data['sender'];
            final messageText = message.data['text'];
            final createdAt = message.data['createdAt'].toDate();
            final currentUser = globals.email;

            //final dtFormat = DateFormat.yMEd().add_jms().format(createdAt);

            if (messageText != null) {
              final messageBubble = MessageBubble(
                  text: messageText,
                  createAt: createdAt,
                  isMe: currentUser == sender);
              messageBubbles.add(messageBubble);
            }
          }
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 6.0,vertical: 10.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> returnQuerySnapshots () {
    return  Firestore.instance.collection('messages').where('room', isEqualTo: globals.roomDoc).orderBy('createdAt').snapshots();
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final DateTime createAt;
  final bool isMe;
  MessageBubble({this.text, this.createAt, this.isMe});


  @override
  Widget build(BuildContext context) {
    var date;
    return Padding(
      padding: EdgeInsets.all(10.0),
      child:Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.start: CrossAxisAlignment.end,
        children: [
          Text(DateFormat.yMEd().add_jms().format(createAt),
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black54,
          ),),
          Material(
            borderRadius: isMe? BorderRadius.only(topRight: Radius.circular(30.0),bottomRight: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0)):
            BorderRadius.only(topLeft: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
              child: Text('$text',
                style: TextStyle(
                  color: isMe ? Colors.white: Colors.black,
                  fontSize: 15.0,
                ),),
            ),
          ),
        ],
      ),
    );
  }
}

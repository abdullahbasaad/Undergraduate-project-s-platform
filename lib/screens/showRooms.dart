import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduater/api/graduater_api.dart';
import 'package:graduater/components/screenTitleWidget.dart';
import 'package:graduater/models/globals.dart' as globals;
import 'package:graduater/models/mainRooms.dart';
import 'package:graduater/screens/chat.dart';
import 'package:graduater/screens/showProjects.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

final _textFieldController = TextEditingController();
String receiver;

class ShowRooms extends StatefulWidget {
  @override
  _ShowRoomsState createState() => _ShowRoomsState();
}

class _ShowRoomsState extends State<ShowRooms> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _semicircleController = ScrollController();
  List<MainRooms> _roomsSender = [];
  List<MainRooms> _roomsReceiver = [];
  List<MainRooms> _rooms = [];


  @override
  void initState() {
    setState(() {
    });
    super.initState();
    _showAllRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: ScreenTitleWidget(screenTitle: 'CHATS'),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShowProjects()),
            );
          },
        ),
      ),
      body: DraggableScrollbar.semicircle(
        controller: _semicircleController,
        child: ListView.builder(
          controller: _semicircleController,
          itemCount: _rooms.length,
          itemBuilder: (_, index) {
            return GestureDetector(
              onTap: () async{
                print(receiver);
                print(_rooms[index].docId);
                globals.roomDoc = _rooms[index].docId;
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Chat(room: _rooms[index].docId, receiver: _rooms[index].receiver, sender: _rooms[index].sender),
                    ));
                Navigator.pop(context);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
                margin: const EdgeInsets.all(3.0),
                color: Colors.white,
                child: ListTile(
                  leading: Icon(Icons.account_circle,
                  size: 40.0),
                  title: Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child:  FutureBuilder<String>(
                      future: _returnReceiverName(_rooms[index].receiver==globals.email?_rooms[index].sender:_rooms[index].receiver), // a previously-obtained Future<String> or null
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),);
                        }else
                          return Container();
                      },
                    ),
                  ),

                  subtitle: Container(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child:  FutureBuilder<String>(
                    future: getStudentCourse(_rooms[index].receiver==globals.email?_rooms[index].sender:_rooms[index].receiver), // a previously-obtained Future<String> or null
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                          ),);
                      }else
                        return Text('Staff',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                          ),);
                    },
                  ),
                 ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton:
      Container(
        height: 45.0,
        width: 45.0,
        child: FloatingActionButton(
            child: Icon(Icons.add,
              size: 20.0,
              color: Colors.white),
            onPressed: showMyDialog),
      ),
    );
  }

  Future<String> _returnReceiverName(String email) async {
    String name;
    name = await getUserNameFromEmail(email);
    if (name!=null)
      return name;
    else
      return '?';
  }

  _showAllRooms() async{
    _roomsSender = await getRoomListAsSender();
    _roomsReceiver = await getRoomListAsReceiver();
    _rooms.addAll(_roomsSender);
    _rooms.addAll(_roomsReceiver);
    setState(() {
    });
  }

  Future<List<MainRooms>> getRoomListAsSender() async {
    QuerySnapshot qShot = await getAllUserRoomsAsSender(globals.email);

    return qShot.documents.map(
            (doc) => MainRooms(
            doc.documentID,
            doc.data['sender'],
            doc.data['receiver'],
            doc.data['createdBy'])
    ).toList();
  }

  Future<List<MainRooms>> getRoomListAsReceiver() async {
    QuerySnapshot qShot = await getAllUserRoomsAsReceiver(globals.email);

    return qShot.documents.map(
            (doc) => MainRooms(
            doc.documentID,
            doc.data['sender'],
            doc.data['receiver'],
            doc.data['createdBy'])
    ).toList();
  }

   showMyDialog() async {
     return showDialog(
         context: context,
         builder: (context) {
           return AlertDialog(
             title: Text('Please enter the email address'),
             content: TextField(
               controller: _textFieldController,
               onChanged: (value) {
                 setState(() {
                   receiver = value;
                 });
               },
               decoration: InputDecoration(hintText: "EMAIL ADDRESS"),
             ),
             actions: <Widget>[
               FlatButton(
                 color: Colors.blue[900],
                 textColor: Colors.white,
                 child: Text('CANCEL'),
                 onPressed: () {
                   _textFieldController.text = null;
                   setState(() {
                     Navigator.pop(context);
                   });
                 },
               ),
               FlatButton(
                 color: Colors.green,
                 textColor: Colors.white,
                 child: Text('OK'),
                 onPressed: () async {
                   if (await checkEmailAddress(receiver)) {
                     String sender = globals.email;
                     String roomDoc = await checkRoomExists(sender, receiver);
                     if (roomDoc == null) {
                       String newRoom = Uuid().v4();
                       globals.roomDoc = newRoom;
                       await addNewRoom(newRoom, sender, receiver);
                       roomDoc = newRoom;
                     }
                     Navigator.push(
                         context,
                         MaterialPageRoute(
                             builder: (context) =>
                                 Chat(room: roomDoc, receiver: receiver, sender: sender)
                         ));
                   }else
                     Alert(
                       context: context,
                       title: "Warning!",
                       desc: "Email address doesn't exist!!",
                       image: Image.asset("images/fail.png"),
                     ).show();
                 }
               ),
             ],
           );
         });
   }
}

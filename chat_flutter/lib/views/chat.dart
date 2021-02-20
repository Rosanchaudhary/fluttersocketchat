import 'dart:async';

import 'package:chat_flutter/components/chat_detail_appbar.dart';
import 'package:chat_flutter/models/message_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;
  void dispose() {
    _socketResponse.close();
  }
}

class ChatPage extends StatefulWidget {
  final String username;
  final String conversationId;
  final String reciverId;
  ChatPage({this.username, this.conversationId, this.reciverId});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatPage> {
  final TextEditingController _message = TextEditingController();
  StreamSocket streamSocket = StreamSocket();

  IO.Socket socket = io('http://10.0.2.2:3000', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });
  void connectToServer() async {
    final storage = new FlutterSecureStorage();
    String sender = await storage.read(key: "user_id");

    //connect to web socket
    socket.connect();
    socket.emit('userId', sender);
    //socket.emit("new message","hello");
  }

  Future<void> sendMessage(String message) async {
    final storage = new FlutterSecureStorage();
    String sender = await storage.read(key: "user_id");
    var msg = <String, String>{
      'sender': sender,
      'reciver': widget.reciverId,
      'conversation': widget.conversationId,
      'message': message
    };
    //print(msg);
    socket.emit("send message", msg);
  }

  void getMessage() {
    socket.emit('conversation', widget.conversationId);
    socket.on('chat message', (data) => streamSocket.addResponse);
  }

  void showModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height / 2,
            color: Color(0xff737373),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: Container(
                      height: 4,
                      width: 50,
                      color: Colors.grey.shade200,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // ListView.builder(
                  //   itemCount: menuItems.length,
                  //   shrinkWrap: true,
                  //   physics: NeverScrollableScrollPhysics(),
                  //   itemBuilder: (context, index){
                  //     return Container(
                  //       padding: EdgeInsets.only(top: 10,bottom: 10),
                  //       child: ListTile(
                  //         leading: Container(
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(30),
                  //             color: menuItems[index].color.shade50,
                  //           ),
                  //           height: 50,
                  //           width: 50,
                  //           child: Icon(menuItems[index].icons,size: 20,color: menuItems[index].color.shade400,),
                  //         ),
                  //         title: Text(menuItems[index].text),
                  //       ),
                  //     );
                  //   },
                  // )
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    connectToServer();
    getMessage();
  }

  @override
  Widget build(BuildContext context) {
    //print(streamSocket.getResponse.first.toString());
    return Scaffold(
      appBar: ChatDetailPageAppBar(
        username: widget.username,
      ),
      body: Stack(
        children: <Widget>[
          //   ListView.builder(
          //     itemCount: chatMessage.length,
          //     shrinkWrap: true,
          //     padding: EdgeInsets.only(top: 10,bottom: 10),
          //     physics: NeverScrollableScrollPhysics(),
          //     itemBuilder: (context, index){
          //     return ChatBubble(
          //       chatMessage: chatMessage[index],
          //     );
          //     },
          //  ),
          StreamBuilder(
              stream: streamSocket.getResponse,
              builder: (context, snapshot) {
                print(snapshot.hasData);
                if (snapshot.hasData) {
                  return Container(
                    child: Text(snapshot.data),
                  );
                } else {
                  //print(snapshot.error);
                }
                return CircularProgressIndicator();
              }),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 16, bottom: 10),
              height: 80,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      showModal();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _message,
                      decoration: InputDecoration(
                          hintText: "Type message...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: EdgeInsets.only(right: 30, bottom: 50),
              child: FloatingActionButton(
                onPressed: () {
                  sendMessage(_message.text);
                },
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                backgroundColor: Colors.pink,
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }
}

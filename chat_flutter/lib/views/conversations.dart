import 'dart:convert';
import 'dart:io';
import 'package:chat_flutter/components/conversation_list.dart';
import 'package:chat_flutter/views/users.dart';
import 'package:chat_flutter/models/conversation_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

Future<List<Conversation>> fetchConversations() async {
  final storage = new FlutterSecureStorage();
  String value = await storage.read(key: "x-auth-token");
  final response = await http
      .get('http://10.0.2.2:3000/conversation', headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    HttpHeaders.authorizationHeader: value
  });

  if (response.statusCode == 200) {
    var tagObjsJson = jsonDecode(response.body) as List;
    List<Conversation> tagObjs =
        tagObjsJson.map((tagJson) => Conversation.fromJson(tagJson)).toList();

    return tagObjs;
  } else {
    throw Exception('Failed to load album');
  }
}

class ConversationsScreen extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ConversationsScreen> {
  Future<List<Conversation>> conversations;

  @override
  void initState() {
    super.initState();
    conversations = fetchConversations();
    //connectToServer();
  }

  Future<String> myId() async {
    final storage = new FlutterSecureStorage();
    String value = await storage.read(key: "user_id");
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Container(
                color: Colors.blueAccent,
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Chats",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Users()));
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 8, right: 8, top: 2, bottom: 2),
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "New",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.09,
              decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25))),
              child: Padding(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    //hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white38,
                    contentPadding: EdgeInsets.all(8),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blueAccent)),
                  ),
                ),
              ),
            ),
            FutureBuilder<List<Conversation>>(
                future: conversations,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 16),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        print(snapshot.data[index].users[0].username);
                        return ConversationList(
                          // ignore: unrelated_type_equality_checks
                          username: snapshot.data[index].users[0].id == myId() ? snapshot.data[index].users[0].username:snapshot.data[index].users[1].username,
                           // ignore: unrelated_type_equality_checks
                           reciverId: snapshot.data[index].users[0].id == myId() ? snapshot.data[index].users[0].id:snapshot.data[index].users[1].id,
                           conversationId: snapshot.data[index].id,
                           
                          //email: snapshot.data[index].email,

                          // time: chatUsers[index].time,
                          // isMessageRead: (index == 0 || index == 3) ? true : false,
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  // By default, show a loading spinner.
                  return CircularProgressIndicator();
                })
          ],
        ),
      ),
    );
  }
}

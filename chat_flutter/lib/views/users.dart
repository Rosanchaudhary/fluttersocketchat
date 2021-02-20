import 'dart:convert';
import 'dart:io';

import 'package:chat_flutter/components/chat_list.dart';
import 'package:chat_flutter/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

Future<List<User>> getUser() async {
  final storage = new FlutterSecureStorage();
  String value = await storage.read(key: "x-auth-token");
  final response =
      await http.get('http://10.0.2.2:3000/users', headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    HttpHeaders.authorizationHeader: value
  });

  if (response.statusCode == 200) {
    var tagObjsJson = jsonDecode(response.body) as List;
    List<User> tagObjs =
        tagObjsJson.map((tagJson) => User.fromJson(tagJson)).toList();

    return tagObjs;
  } else {
    throw Exception("failed to load");
  }
}

class Users extends StatefulWidget {
  @override
  _UsersState createState() => _UsersState();

  
}

class _UsersState extends State<Users> {
  Future<List<User>> users;
  @override
  void initState() {
    super.initState();
    users = getUser();
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
                    children: <Widget>[
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back_sharp)),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Users",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
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
            FutureBuilder<List<User>>(
                future: users,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data[0].username);
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 16),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatUsersList(
                          userId: snapshot.data[index].id,
                          username: snapshot.data[index].username,
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
                }),
          ],
        ),
      ),
    );
  }
}

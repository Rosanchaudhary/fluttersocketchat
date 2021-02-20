import 'package:chat_flutter/models/user_model.dart';

class Conversation {
  final String id;
  final List<User> users;

  Conversation({this.id, this.users});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    var list = json['users'] as List;
    List<User> userList = list.map((e) => User.fromJson(e)).toList();
    return Conversation(id: json['_id'], users: userList);
  }
}

class Message {
  final String id;
  final String message;

  Message({this.id, this.message});

    factory Message.fromJson(Map<String, dynamic> json) {    
    return Message(
        id: json['_id'],
        message: json['message'],
        );
  }
}

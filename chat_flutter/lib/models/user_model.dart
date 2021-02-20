class User {
  final String id;
  final String username;
  final String email;


  User(
      {this.id,
      this.username,
      this.email});

  factory User.fromJson(Map<String, dynamic> json) {    
    return User(
        id: json['_id'],
        username: json['username'],
        email: json['email']
        );
  }
}

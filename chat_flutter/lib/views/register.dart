import 'package:chat_flutter/views/conversations.dart';
import 'package:chat_flutter/views/login.dart';
import 'package:flutter/material.dart';
import '../components/rounded_button.dart';
import '../constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<int> createUser(String username, String email, String password) async {
  final http.Response response = await http.post("http://10.0.2.2:3000/users",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
      }));
  if (response.statusCode == 200) {
    print(response.headers['x-auth-token']);
    final storage = new FlutterSecureStorage();
    await storage.write(
        key: "x-auth-token", value: response.headers['x-auth-token']);
    print(response.statusCode);
    return response.statusCode;
  } else {
    throw Exception("failed to load");
  }
}

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool checkedStatus = false;
  final dateController = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  Future<int> _futureUser;

  @override
  void dispose() {
    dateController.dispose(); //Dispose controller when widget removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: (_futureUser == null)
            ? Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "SIGN UP",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) return "Enter a valid text";
                        return null;
                      },
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          kTextFieldDecoration.copyWith(hintText: "Email*"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      readOnly: false,
                      validator: (value) {
                        if (value.isEmpty) return "Enter a valid value";
                        return null;
                      },
                      controller: _username,
                      textAlign: TextAlign.left,
                      decoration:
                          kTextFieldDecoration.copyWith(hintText: "Username*"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _password,
                      validator: (value) {
                        if (value.isEmpty) return "Enter a valid value";
                        return null;
                      },
                      textAlign: TextAlign.left,
                      obscureText: true,
                      decoration:
                          kTextFieldDecoration.copyWith(hintText: "Password*"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _confirmPassword,
                      validator: (value) {
                        if (value.isEmpty) return "Enter a valid value";
                        if (value != _password.text)
                          return 'Passwords doesn\'t match';
                        return null;
                      },
                      textAlign: TextAlign.left,
                      obscureText: true,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: " Conform Password*"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: CheckboxListTile(
                        title: Text(
                          "I agree to terms and condition ",
                        ),
                        value: checkedStatus,
                        controlAffinity: ListTileControlAffinity.leading,
                        subtitle: !checkedStatus
                            ? Text(
                                'Required.',
                                style: TextStyle(color: Colors.red),
                              )
                            : null,
                        activeColor: Colors.lightGreen,
                        onChanged: (value) {
                          setState(() {
                            checkedStatus = value;
                          });
                        },
                      ),
                    ),
                    Center(
                      child: RoundedButton(
                        onPressed: () {
                          if (checkedStatus == false)
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text("Alert"),
                                content: Text(
                                    "You have not accepted terms and conditioni"),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Text("Okay"),
                                  ),
                                ],
                              ),
                            );
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _futureUser = createUser(
                                  _username.text, _email.text, _password.text);
                            });
                          }
                        },
                        colour: Colors.green,
                        title: "Sign Up",
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return LoginScreen();
                              },
                            ),
                          );

                          /// IMPLLEMENTATION OF FORGOT PASSWORD
                        },
                        child: Text("Sign in instead"),
                      ),
                    ),
                  ],
                ),
              )
            : FutureBuilder<int>(
                future: _futureUser,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == 200) {
                      Future.delayed(Duration.zero, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConversationsScreen()));
                      });
                    }
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  return CircularProgressIndicator();
                },
              ),
      ),
    );
  }
}

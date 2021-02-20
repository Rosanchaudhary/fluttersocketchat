import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({this.colour , this.title , @required this.onPressed});

  final Color colour;
  final String title;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:EdgeInsets.symmetric(vertical:16.0),
      child: Material(
        elevation: 10,
        color: colour,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          height: 42.0,
          minWidth: 100,
          onPressed:onPressed,
          child: Text(
              title
          ),
        ),
      ),
    );
  }
}
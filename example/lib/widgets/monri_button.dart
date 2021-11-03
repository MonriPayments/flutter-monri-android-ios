import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MonriButton extends StatelessWidget{

  // void Function() onPressCallback;
  final VoidCallback onPressCallback;
  final String text;

  MonriButton(this.onPressCallback, this.text);

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(
      onPressed: onPressCallback,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

}
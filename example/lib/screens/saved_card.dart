import 'package:flutter/material.dart';

import '../models/object_argument.dart';

class SavedCard extends StatelessWidget{
  final ObjectArgument objectArgument;

  SavedCard({Key? key, required this.objectArgument});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Pay with saved card'),
            ),
            body: Text('Saved Card ${objectArgument.threeDS}')));
  }

}
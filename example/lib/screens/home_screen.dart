import 'package:MonriPayments_example/models/object_argument.dart';
import 'package:MonriPayments_example/widgets/monri_button.dart';
import 'package:flutter/material.dart';

import '../routes.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Monri Flutter Plugin example app'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              MonriButton(() => {
                    Navigator.pushNamed(
                        context, AvailableAppRoutes.NEW_PAYMENT,
                        arguments: {'req_arg': ObjectArgument(false, false)}
                        )
                  },
                  'new payment'
              ),
              MonriButton(() => {
                    Navigator.pushNamed(
                        context, AvailableAppRoutes.NEW_PAYMENT,
                        arguments: {'req_arg': ObjectArgument(true, false)}
                    )
                  },
                  'new payment save card'
              ),
              MonriButton(() => {
                Navigator.pushNamed(
                    context, AvailableAppRoutes.NEW_PAYMENT,
                    arguments: {'req_arg': ObjectArgument(false, true)}
                )
              },
                  'new payment 3DS'
              ),
              MonriButton(() => {
                Navigator.pushNamed(
                    context, AvailableAppRoutes.NEW_PAYMENT,
                    arguments: {'req_arg': ObjectArgument(true, true)}
                )
              },
                  'new payment 3DS save card'
              ),
              MonriButton(() => {
                Navigator.pushNamed(
                    context, AvailableAppRoutes.SAVED_CARD,
                    arguments: {'req_arg': ObjectArgument(true, false)}
                )
              },
                  'pay with saved card'
              ),
              MonriButton(() => {
                Navigator.pushNamed(
                    context, AvailableAppRoutes.SAVED_CARD,
                    arguments: {'req_arg': ObjectArgument(true, true)}
                )
              },
                  'pay with 3DS saved card'
              )
            ],
          ),
        ),
      ),
    );
  }
}

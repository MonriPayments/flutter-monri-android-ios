import 'package:MonriPayments_example/routes.dart';
import 'package:MonriPayments_example/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    onGenerateRoute: AppRoutes.onGenerateRoutes,
    home: Home(),
  ));
}
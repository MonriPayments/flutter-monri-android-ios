import 'package:MonriPayments_example/routes.dart';
import 'package:MonriPayments_example/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MaterialApp(
    onGenerateRoute: AppRoutes.onGenerateRoutes,
    home: Home(),
  ));
}


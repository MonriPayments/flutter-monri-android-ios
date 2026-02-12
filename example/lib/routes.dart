import 'package:MonriPayments_example/screens/photo_cature.dart';
import 'package:flutter/material.dart';
import 'models/object_argument.dart';
import 'screens/home_screen.dart';
import 'screens/new_payment.dart';
import 'screens/saved_card.dart';

class AvailableAppRoutes{
  static const String HOME = '/';
  static const String NEW_PAYMENT = '/new_payment';
  static const String SAVED_CARD = '/saved_card';
  static const String PHOTO_CAPTURE = '/photo_capture';
}

class AppRoutes {
  static Route? onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case AvailableAppRoutes.HOME:
        return _materialRoute(Home());
      case AvailableAppRoutes.NEW_PAYMENT:
        final arguments = settings.arguments as Map;

        return _materialRoute(NewPayment(objectArgument: arguments['req_arg'] as ObjectArgument));
      case AvailableAppRoutes.SAVED_CARD:
        final arguments = settings.arguments as Map;

        return _materialRoute(SavedCard(objectArgument: arguments['req_arg'] as ObjectArgument));
      case AvailableAppRoutes.PHOTO_CAPTURE:
        return _materialRoute(CameraScreen());
      default:
        return null;
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
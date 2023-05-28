// ignore_for_file: unused_local_variable

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tricycall_thesis/controller/notification_controller.dart';
import 'package:tricycall_thesis/pages/splash_screen.dart';

import 'controller/auth_controller.dart';
import 'controller/driver_controller.dart';
import 'controller/passenger_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    Get.snackbar("Permission not Accepted",
        "Grant notification permission to receive notifications");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());
    PassengerController passengerController = Get.put(PassengerController());
    DriverController driverController = Get.put(DriverController());
    NotificationController notificationController =
        Get.put(NotificationController());

    final textTheme = Theme.of(context).textTheme;

    return GetMaterialApp(
      title: 'Tricycall Thesis',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.varelaRoundTextTheme(textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}

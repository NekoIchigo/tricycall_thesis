import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tricycall_thesis/pages/login_page.dart';

import 'controller/auth_controller.dart';
import 'firebase_options.dart';
import 'pages/account_setting_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());
    authController.decideRoute();
    final textTheme = Theme.of(context).textTheme;

    return GetMaterialApp(
      title: 'Tricycall Thesis',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.varelaRoundTextTheme(textTheme),
      ),
      home: const LoginPage(),
    );
  }
}

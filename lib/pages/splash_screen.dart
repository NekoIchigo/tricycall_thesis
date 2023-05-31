import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AuthController authController = Get.find<AuthController>();

  restartLocalStorage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    localStorage.setString("payment_method", "CASH");
    localStorage.setString("note_to_driver", "");
    localStorage.setString("source", "");
    localStorage.setString("destination", "");
    localStorage.setString("total_distance", "");
    localStorage.setDouble("travel_price", 0.0);
    localStorage.setBool("isDriverInit", false);
  }

  startTimer() {
    Timer(const Duration(seconds: 3), () {
      authController.decideRoute();
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    authController.getToken();
    restartLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo_title.png",
              height: Get.height * 0.40,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tricycall_thesis/pages/login_page.dart';

import '../controller/auth_controller.dart';
import '../widgets/center_logo.dart';
import '../widgets/otp_verification_widget.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    authController.phoneAuth(widget.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                centerLogo(),
                Positioned(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade300,
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            otpVerificationWidget(),
          ],
        ),
      ),
    );
  }
}

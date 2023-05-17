import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tricycall_thesis/widgets/center_logo.dart';

import '../controller/auth_controller.dart';
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
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.green,
                size: 20,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            width: Get.width,
            child: bottomGreen(
              otpVerificationWidget(),
            ),
          ),
          Positioned(
            width: Get.width,
            bottom: Get.height * 0.43,
            child: centerLogo(),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

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
  bool canResend = false;
  final CountdownController _controller = CountdownController(autoStart: true);

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
            child: Column(
              children: [
                bottomGreen(
                  otpVerificationWidget(),
                ),
              ],
            ),
          ),
          Positioned(
              bottom: Get.height * .10,
              width: Get.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Resend Code ",
                    style: GoogleFonts.varelaRound(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      canResend
                          ? authController.phoneAuth(widget.phoneNumber)
                          : null;

                      _controller.restart();
                      setState(() {
                        canResend = false;
                      });
                    },
                    child: Countdown(
                      controller: _controller,
                      seconds: 120,
                      build: (BuildContext context, double time) {
                        return Text(
                            canResend ? "Tap here" : time.toStringAsFixed(0),
                            style: GoogleFonts.varelaRound(
                              fontSize: 12,
                              color: Colors.white,
                            ));
                      },
                      interval: const Duration(seconds: 1),
                      onFinished: () {
                        setState(() {
                          canResend = true;
                        });
                      },
                    ),
                  )
                ],
              )),
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

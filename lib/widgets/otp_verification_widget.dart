import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tricycall_thesis/widgets/text_widget.dart';

import 'pinput_widget.dart';

Widget otpVerificationWidget() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget(text: "Phone Verification:"),
        textWidget(
          text: "Enter your OTP code below",
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(
          height: 40,
        ),
        SizedBox(
          width: Get.width,
          child: const RoundedWithCustomCursor(),
        ),
        const SizedBox(
          height: 40,
        ),
        RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
            style: GoogleFonts.varelaRound(color: Colors.black, fontSize: 12),
            children: [
              const TextSpan(
                text: "Resend code in: ",
              ),
              TextSpan(
                text: "60 seconds",
                style: GoogleFonts.varelaRound(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

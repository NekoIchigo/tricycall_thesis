import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tricycall_thesis/widgets/pinput_widget.dart';
import 'package:tricycall_thesis/widgets/text_widget.dart';

Widget otpVerificationWidget() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        textWidget(text: "Verify your phone number"),
        textWidget(
            text: "Enter the OTP Code below",
            fontSize: 22,
            fontWeight: FontWeight.bold),
        const SizedBox(height: 40),
        SizedBox(
            width: Get.width, height: 50, child: const RoundedWithShadow()),
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                children: [
                  const TextSpan(
                    text: "Resend Code: ",
                  ),
                  TextSpan(
                      text: "10 seconds",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ]),
          ),
        )
      ],
    ),
  );
}

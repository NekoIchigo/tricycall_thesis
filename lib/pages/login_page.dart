import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tricycall_thesis/pages/driver/driver_application_page.dart';
import 'package:tricycall_thesis/pages/otp_verification_page.dart';

import '../widgets/center_logo.dart';
import '../widgets/login_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final countryPicker = const FlCountryCodePicker();

  CountryCode countryCode =
      const CountryCode(name: "Philippines", code: "PH", dialCode: "+63");

  onSubmit(String? input) {
    Get.to(() => OtpVerificationPage(
          phoneNumber: countryCode.dialCode + input!,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            width: Get.width,
            bottom: 0,
            child: bottomGreen(
              loginWidget(countryCode, () async {
                final code = await countryPicker.showPicker(context: context);
                // Null check
                if (code != null) countryCode = code;
                setState(() {});
              }, onSubmit),
            ),
          ),
          Positioned(
            width: Get.width,
            bottom: Get.height * .43,
            child: centerLogo(),
          ),
          Positioned(
            bottom: Get.height * .88,
            right: 15,
            child: applyButton(),
          ),
        ],
      ),
    );
  }

  ElevatedButton applyButton() {
    return ElevatedButton(
      onPressed: () {
        Get.to(() => const DriverApplicationPage());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Colors.green,
          ),
        ),
      ),
      child: Text(
        "Apply as Driver",
        style: GoogleFonts.varelaRound(fontSize: 12, color: Colors.green),
      ),
    );
  }
}

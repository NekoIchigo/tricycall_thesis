import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    Get.to(
        () => OtpVerificationPage(phoneNumber: countryCode.dialCode + input!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              centerLogo(),
              const SizedBox(height: 50),
              loginWidget(countryCode, () async {
                final code = await countryPicker.showPicker(context: context);
                // Null check
                if (code != null) countryCode = code;
                setState(() {});
              }, onSubmit),
            ],
          ),
        ),
      ),
    );
  }
}

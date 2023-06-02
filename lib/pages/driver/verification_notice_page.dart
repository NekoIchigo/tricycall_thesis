import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tricycall_thesis/pages/login_page.dart';

class VerificationNoticePage extends StatefulWidget {
  const VerificationNoticePage({super.key});

  @override
  State<VerificationNoticePage> createState() => _VerificationNoticePageState();
}

class _VerificationNoticePageState extends State<VerificationNoticePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: Get.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                ),
                Center(
                  child: Text(
                    "APPLY AS DRIVER",
                    style: GoogleFonts.varelaRound(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: Get.height * .10),
                Image.asset(
                  "assets/images/sided_tricycle.png",
                  width: Get.width * .75,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: Get.height * .10),
                SizedBox(
                  width: Get.width * .75,
                  child: Text(
                    "WE WILL SEND YOU AN EMAIL AND TEXT MESSAGE ONCE YOUR ACCOUNT IS VERIFIED.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.varelaRound(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: Get.height * .05),
                Container(
                  width: Get.width,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => const LoginPage());
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "OKAY",
                      style: GoogleFonts.varelaRound(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

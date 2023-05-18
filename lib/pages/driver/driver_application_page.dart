import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tricycall_thesis/widgets/input_text.dart';

import 'verification_notice_page.dart';

class DriverApplicationPage extends StatefulWidget {
  const DriverApplicationPage({super.key});

  @override
  State<DriverApplicationPage> createState() => _DriverApplicationPageState();
}

class _DriverApplicationPageState extends State<DriverApplicationPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobilePhoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController operatorNameController = TextEditingController();
  TextEditingController bodyNumberController = TextEditingController();

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
                const SizedBox(height: 20),
                InputText(
                  textController: firstNameController,
                  label: "First Name",
                  isPassword: false,
                  icon: Icons.abc,
                  keyboardtype: TextInputType.name,
                  validator: () {},
                ),
                InputText(
                  textController: lastNameController,
                  label: "Last Name",
                  isPassword: false,
                  icon: Icons.abc,
                  keyboardtype: TextInputType.name,
                  validator: () {},
                ),
                InputText(
                  textController: mobilePhoneController,
                  label: "Mobile Phone",
                  isPassword: false,
                  icon: Icons.phone_android,
                  keyboardtype: TextInputType.number,
                  validator: () {},
                ),
                InputText(
                  textController: mobilePhoneController,
                  label: "Email",
                  isPassword: false,
                  icon: Icons.email_rounded,
                  keyboardtype: TextInputType.emailAddress,
                  validator: () {},
                ),
                InputText(
                  textController: mobilePhoneController,
                  label: "License",
                  isPassword: false,
                  icon: Icons.upload_rounded,
                  keyboardtype: TextInputType.name,
                  validator: () {},
                ),
                InputText(
                  textController: mobilePhoneController,
                  label: "Operator Name",
                  isPassword: false,
                  icon: Icons.person,
                  keyboardtype: TextInputType.name,
                  validator: () {},
                ),
                InputText(
                  textController: mobilePhoneController,
                  label: "Body Number(Tricycle Number)",
                  isPassword: false,
                  icon: Icons.onetwothree,
                  keyboardtype: TextInputType.name,
                  validator: () {},
                ),
                InputText(
                  textController: mobilePhoneController,
                  label: "Photo of Tricycle",
                  isPassword: false,
                  icon: Icons.upload_rounded,
                  keyboardtype: TextInputType.name,
                  validator: () {},
                ),
                const SizedBox(height: 20),
                Text(
                  "BY CREATING AN ACCOUNT YOU AGREE TO OUR",
                  style: GoogleFonts.varelaRound(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "TERMS OF SERVICE AND PRIVACY POLICY",
                  style: GoogleFonts.varelaRound(
                    fontSize: 10,
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: Get.width,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => const VerificationNoticePage());
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "SUBMIT",
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

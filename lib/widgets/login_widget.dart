import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import 'text_widget.dart';

Widget loginWidget(Function onSubmit) {
  TextEditingController phoneNumberController = TextEditingController();
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        textWidget(text: "Welcome to our Ride hailing app!"),
        textWidget(
          text: "Get moving with Tricycall",
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 40),
        Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 3,
                blurRadius: 3,
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  const SizedBox(width: 5),
                  const Expanded(
                    child: Image(
                      image: AssetImage("assets/images/ph_flag.png"),
                      width: 30,
                      height: 50,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text("+63",
                        style: GoogleFonts.varelaRound(fontSize: 12)),
                  )
                ],
              ),
            ),
            Container(
              width: 1,
              height: 55,
              color: Colors.black.withOpacity(0.2),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  controller: phoneNumberController,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintStyle: GoogleFonts.varelaRound(
                        fontSize: 12, fontWeight: FontWeight.normal),
                    hintText: "Enter your mobile number",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                phoneNumberController.length < 10
                    ? Get.snackbar(
                        "Invalid Number", "Please enter a valid number",
                        backgroundColor: Colors.red.shade200)
                    : onSubmit(phoneNumberController.text);
              },
              icon: const Icon(Icons.navigate_next),
            ),
          ]),
        ),
        const SizedBox(
          height: 40,
        ),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.varelaRound(color: Colors.white, fontSize: 12),
              children: [
                const TextSpan(
                  text: "By Creating an Account you Agree to our ",
                ),
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      String paragh1 =
                          "Please read these terms and conditions carefully before using the TricyCall mobile application.";
                      String paragh2 =
                          "By downloading, installing, and using the TricyCall app, you agree to comply with these terms and conditions. If you do not agree with any of the provisions stated herein, please refrain from using the application.";
                      String paragh3 =
                          "As a user of TricyCall, you are responsible for providing accurate and up-to-date information during registration. You must also adhere to the applicable laws and regulations governing transportation services.";
                      String paragh4 =
                          "TricyCall strives to provide uninterrupted and reliable service. However, we do not guarantee the continuous availability of the app and may temporarily suspend or terminate the service for maintenance or other reasons.";
                      String paragh5 =
                          "We value your privacy and handle your personal data in accordance with our Privacy Policy. By using TricyCall, you consent to the collection, use, and disclosure of your information as described in the Privacy Policy.";
                      String paragh6 =
                          "The TricyCall app and all its contents, including logos, trademarks, and intellectual property, are owned by TricyCall or its affiliates. You agree not to reproduce, modify, or distribute any of the app's content without prior written permission.";
                      String paragh7 =
                          "TricyCall shall not be liable for any direct, indirect, incidental, or consequential damages arising from your use of the app or any third-party services accessed through the app.";
                      String paragh8 =
                          "These terms and conditions shall be governed by and construed in accordance with the laws of the jurisdiction in which TricyCall operates.";
                      String paragh9 =
                          "By using the TricyCall app, you acknowledge that you have read, understood, and agreed to these terms and conditions. If you have any questions or concerns, please contact us at support@tricycall.com.";

                      Get.defaultDialog(
                          title: "Terms of Service",
                          confirm: ElevatedButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text("CONFIRM")),
                          contentPadding: EdgeInsets.all(20),
                          content: SizedBox(
                            width: Get.width,
                            height: Get.height * .50,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    paragh1,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "1. Acceptance of Terms",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh2,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "2. User Responsibilities",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh3,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "3. Service Availability",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh4,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "4. Privacy and Data Protection",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh5,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "5. Intellectual Property",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh6,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "6. Limitation of Liability",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh7,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "7. Governing Law",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh8,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    paragh9,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                ],
                              ),
                            ),
                          ));
                    },
                  text: "Terms of Service ",
                  style: GoogleFonts.varelaRound(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const TextSpan(
                  text: "and ",
                ),
                TextSpan(
                  text: "Privacy Policy ",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      String paragh1 =
                          "This Privacy Policy describes how TricyCall collects, uses, and protects the personal information you provide when using the TricyCall mobile application.";
                      String paragh2 =
                          "TricyCall collects personal information such as your name, contact details, and location when you register for an account or use the app's features. We may also collect non-personal information such as device information and usage statistics.";
                      String paragh3 =
                          "We use the collected information to provide and improve our services, customize your experience, and communicate with you. We may also use the information for analytics, research, and marketing purposes.";
                      String paragh4 =
                          "TricyCall may share your personal information with trusted third-party service providers to facilitate the app's functionality. We do not sell, rent, or trade your personal information to third parties for marketing purposes without your consent.";
                      String paragh5 =
                          "We implement industry-standard security measures to protect your personal information from unauthorized access, disclosure, alteration, or destruction. However, please note that no method of transmission over the internet or electronic storage is completely secure.";
                      String paragh6 =
                          "TricyCall uses cookies and similar tracking technologies to enhance your experience, gather information about usage patterns, and deliver personalized content. You may disable cookies in your browser settings, but this may affect the functionality of the app.";
                      String paragh7 =
                          "The TricyCall app may contain links to third-party websites or services. We are not responsible for the privacy practices or content of these external sites. We recommend reviewing the privacy policies of those websites before providing any personal information.";
                      String paragh8 =
                          "TricyCall reserves the right to update or modify this Privacy Policy at any time. We will notify you of any changes.";

                      Get.defaultDialog(
                          title: "Privacy Policy",
                          confirm: ElevatedButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text("CONFIRM")),
                          content: SizedBox(
                            width: Get.width,
                            height: Get.height * .50,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    paragh1,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "1. Information Collection",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh2,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "2. Use of Information",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh3,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "3. Information Sharing",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh4,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "4. Data Security",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh5,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "5. Cookies and Tracking Technologies",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh6,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "6. Third-Party Links",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh7,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "7. Updates to the Privacy Policy",
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  Text(
                                    paragh8,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.varelaRound(),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ));
                    },
                  style: GoogleFonts.varelaRound(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

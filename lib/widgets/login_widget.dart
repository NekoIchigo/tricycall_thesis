import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import 'text_widget.dart';

Widget loginWidget(
    CountryCode countryCode, Function onCountryChange, Function onSubmit) {
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
              child: InkWell(
                onTap: () => onCountryChange,
                child: Row(
                  children: [
                    const SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        child: countryCode.flagImage(width: 20),
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

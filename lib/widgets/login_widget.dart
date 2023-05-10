import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'text_widget.dart';

Widget loginWidget(
    CountryCode countryCode, Function onCountryChange, Function onSubmit) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget(text: "Welcome to our Ride hailing app!"),
        textWidget(
          text: "Get moving with Tricycall",
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(
          height: 40,
        ),
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
                        child: countryCode.flagImage(width: 26),
                      ),
                    ),
                    textWidget(text: " ${countryCode.dialCode}"),
                    const Icon(Icons.arrow_drop_down_rounded),
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
                  onSubmitted: (String? input) => onSubmit(input),
                  decoration: InputDecoration(
                    hintStyle: GoogleFonts.varelaRound(
                        fontSize: 12, fontWeight: FontWeight.normal),
                    hintText: "Enter your mobile number",
                    border: InputBorder.none,
                  ),
                ),
              ),
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
              style: GoogleFonts.varelaRound(color: Colors.black, fontSize: 12),
              children: [
                const TextSpan(
                  text: "By Creating an Account you Agree to our ",
                ),
                TextSpan(
                  text: "Terms of Service ",
                  style: GoogleFonts.varelaRound(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: "and ",
                ),
                TextSpan(
                  text: "Privacy Policy ",
                  style: GoogleFonts.varelaRound(
                    fontWeight: FontWeight.bold,
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

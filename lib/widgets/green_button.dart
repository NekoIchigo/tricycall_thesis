import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Widget greenButton(String title, Function onPressed) {
  return MaterialButton(
    minWidth: Get.width,
    height: 50,
    color: Colors.green.shade400,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    onPressed: () => onPressed(),
    child: Text(
      title,
      style: GoogleFonts.varelaRound(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}

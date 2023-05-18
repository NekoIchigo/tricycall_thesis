import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget greenButton(String title, Function onPressed) {
  return TextButton(
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

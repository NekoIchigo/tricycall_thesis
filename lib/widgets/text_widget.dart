import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget textWidget({
  required String text,
  double fontSize = 12,
  FontWeight fontWeight = FontWeight.normal,
}) {
  return DefaultTextStyle(
    style: GoogleFonts.varelaRound(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: Colors.white,
    ),
    child: Text(text),
  );
}

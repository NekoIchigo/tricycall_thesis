import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget centerLogo() {
  return Column(
    children: [
      Center(
        child: Image.asset(
          "assets/images/logo_title.png",
          height: Get.height * .30,
          fit: BoxFit.fitHeight,
        ),
      ),
      const SizedBox(height: 35),
      Center(
        child: Image.asset(
          "assets/images/tricycle_icon.png",
          height: Get.height * .08,
          fit: BoxFit.cover,
        ),
      )
    ],
  );
}

Widget bottomGreen(Widget child) {
  return Container(
    height: Get.height * 0.45,
    decoration: const BoxDecoration(
        color: Color(0xFF00bf63),
        borderRadius: BorderRadius.vertical(top: Radius.circular(150))),
    child: child,
  );
}

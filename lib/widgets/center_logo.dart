import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget centerLogo() {
  return Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: Get.height * 0.10),
      child: Image.asset(
        "assets/images/logo_title.png",
        height: Get.height * .30,
        fit: BoxFit.fitHeight,
      ),
    ),
  );
}

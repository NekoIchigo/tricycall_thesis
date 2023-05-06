import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget roundedGreenBg() {
  return Container(
    alignment: Alignment.bottomCenter,
    width: Get.width,
    height: Get.height * 0.6,
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('/images/bg-green-img.png'),
        fit: BoxFit.cover,
      ),
    ),
  );
}

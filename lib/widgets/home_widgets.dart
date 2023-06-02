import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildCurrentLocationIcon() {
  return const CircleAvatar(
    radius: 20,
    backgroundColor: Colors.green,
    child: Icon(
      Icons.my_location,
      color: Colors.white,
    ),
  );
}

Widget buildCurrentNotificationIcon() {
  return const CircleAvatar(
    radius: 20,
    backgroundColor: Colors.white,
    child: Icon(
      Icons.notifications_none_rounded,
    ),
  );
}

Widget buildBottomSheet() {
  return Container(
    width: Get.width * 0.80,
    height: 25,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          spreadRadius: 5,
          blurRadius: 1,
        ),
      ],
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    child: Center(
      child: Container(
        width: Get.width * 0.45,
        height: 5,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    ),
  );
}

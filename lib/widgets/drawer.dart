import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tricycall_thesis/controller/auth_controller.dart';
import 'package:tricycall_thesis/pages/about_page.dart';
import 'package:tricycall_thesis/pages/ride_history_page.dart';

import '../controller/passenger_controller.dart';
import '../pages/account_setting_page.dart';
import '../pages/settings_page.dart';

PassengerController pasengerController = Get.find<PassengerController>();
AuthController authController = Get.find<AuthController>();

Widget buildDrawer() {
  return Drawer(
    child: Stack(
      children: [
        drawerHeader(),
        const SizedBox(height: 20),
        Positioned(
          top: 200,
          width: Get.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: SizedBox(
                  height: Get.height * 0.60,
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          print(
                              "Passenger Id: ${authController.userUID.value}");
                          Get.to(() => RideHistory(
                                userID: authController.userUID.value,
                                userRole: "passenger",
                              ));
                        },
                        contentPadding: const EdgeInsets.all(0),
                        leading: const Icon(
                          Icons.history,
                          color: Colors.green,
                          size: 40,
                        ),
                        title: Text(
                          "RIDE HISTORY",
                          style: GoogleFonts.varelaRound(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Get.to(() => const SettingsPage());
                        },
                        contentPadding: const EdgeInsets.all(0),
                        leading: const Icon(
                          Icons.settings,
                          color: Colors.green,
                          size: 40,
                        ),
                        title: Text(
                          "SETTINGS",
                          style: GoogleFonts.varelaRound(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Get.to(() => const AboutPage());
                        },
                        contentPadding: const EdgeInsets.all(0),
                        leading: const Icon(
                          Icons.info_outline,
                          color: Colors.green,
                          size: 40,
                        ),
                        title: Text(
                          "ABOUT",
                          style: GoogleFonts.varelaRound(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          authController.signOut();
                        },
                        contentPadding: const EdgeInsets.all(0),
                        leading: const RotatedBox(
                          quarterTurns: 2,
                          child: Icon(
                            Icons.logout,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                        title: Text(
                          "LOGOUT",
                          style: GoogleFonts.varelaRound(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: Get.height * .10,
            width: Get.width,
            color: Colors.green,
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Copy Right \u00a9 TricyCall Team",
                  style: GoogleFonts.varelaRound(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );
}

Widget drawerHeader() {
  return SizedBox(
    height: 180,
    child: DrawerHeader(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.green,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              // TODO: Fix draweer
              print("User info: ${pasengerController.myUser.value}");
              Get.to(() => const AccountSettingPage());
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 40,
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: Colors.green.shade900),
                  image: pasengerController.myUser.value.image == null
                      ? const DecorationImage(
                          image: AssetImage(
                            "assets/images/profile-placeholder.png",
                          ),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: NetworkImage(
                              pasengerController.myUser.value.image!),
                          fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            pasengerController.myUser.value.firstName ?? "User",
            style: GoogleFonts.varelaRound(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

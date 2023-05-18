import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tricycall_thesis/pages/ride_history_page.dart';

import '../controller/auth_controller.dart';
import '../pages/account_setting_page.dart';

AuthController authController = Get.find<AuthController>();
Widget buildDrawer() {
  return Drawer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        drawerHeader(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: SizedBox(
                height: Get.height * 0.63,
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Get.to(() => const RideHistory());
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
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      leading: const Icon(
                        Icons.settings,
                        color: Colors.green,
                        size: 40,
                      ),
                      title: Text(
                        "SETTINGS",
                        style: GoogleFonts.varelaRound(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      leading: const Icon(
                        Icons.info_outline,
                        color: Colors.green,
                        size: 40,
                      ),
                      title: Text(
                        "ABOUT",
                        style: GoogleFonts.varelaRound(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
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
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )),
          ),
        ),
        Container(
          height: Get.height * .1135,
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
                "Footer Here",
                style: GoogleFonts.varelaRound(
                  color: Colors.white,
                ),
              ),
              Text(
                "Copy Right \u00a9 TricyCall Team",
                style: GoogleFonts.varelaRound(
                  color: Colors.white,
                ),
              ),
            ],
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
                  image: authController.myUser.value.image == null
                      ? const DecorationImage(
                          image: AssetImage(
                            "assets/images/profile-placeholder.png",
                          ),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image:
                              NetworkImage(authController.myUser.value.image!),
                          fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            authController.myUser.value.firstName ?? "User",
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
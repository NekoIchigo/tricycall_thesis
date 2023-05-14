import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/account_setting_page.dart';
import 'package:tricycall_thesis/controller/auth_controller.dart';

class BuildDrawer extends StatefulWidget {
  const BuildDrawer({super.key});

  @override
  State<BuildDrawer> createState() => _BuildDrawerState();
}

class _BuildDrawerState extends State<BuildDrawer> {
  final List<String> items = ["Ride History", "Settings", "Support", "Log out"];

  AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(() => const AccountSettingPage());
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: authController.myUser.value.image == null
                            ? const DecorationImage(
                                image: AssetImage(
                                  "assets/images/profile-placeholder.png",
                                ),
                                fit: BoxFit.cover,
                              )
                            : DecorationImage(
                                image: NetworkImage(
                                    authController.myUser.value.image!),
                                fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Good Morning",
                        style: GoogleFonts.varelaRound(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        authController.myUser.value.firstName ?? "User",
                        style: GoogleFonts.varelaRound(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: SizedBox(
                height: Get.height * 0.60,
                child: ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      dense: true,
                      onTap: () {},
                      title: Text(
                        items[index],
                        style: GoogleFonts.varelaRound(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const Divider(),
          Padding(
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
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "Copy Right \u00a9 TricyCall Team",
                  style: GoogleFonts.varelaRound(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tricycall_thesis/controller/auth_controller.dart';

AuthController authController = Get.find<AuthController>();

Widget buildProfileTile() {
  return Obx(
    () => authController.myUser.value.firstName == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            padding: const EdgeInsets.all(20),
            width: Get.width * .9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
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
                const SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Good Morning, ",
                            style: GoogleFonts.varelaRound(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text:
                                authController.myUser.value.firstName ?? "User",
                            style: GoogleFonts.varelaRound(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "Where are you going?",
                      style: GoogleFonts.varelaRound(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
  );
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_webservice/places.dart';

import '../pages/account_setting_page.dart';
import '../widgets/build_profile_tile.dart';

// Future<String> showGoogleAutoComplete() async {
//   const kGoogleApiKey = "AIzaSyBFPJ9b4hwLh_CwUAPEe8aMIGT4deavGCk";

//   Prediction? p = await PlacesAutocomplete.show(
//       offset: 0,
//       types: [],
//       radius: 1000,
//       strictbounds: false,
//       region: 'ph',
//       context: context,
//       apiKey: kGoogleApiKey,
//       mode: Mode.overlay, // Mode.fullscreen
//       language: "en",
//       components: [Component(Component.country, "ph")]);

//   return p!.description!;
// }

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

Widget buildDrawer() {
  final List<String> items = ["Ride History", "Settings", "Support", "Log out"];
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
              height: Get.height * 0.60,
              child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    dense: true,
                    onTap: () {
                      authController.signOut();
                    },
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

SizedBox drawerHeader() {
  return SizedBox(
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
                        image: NetworkImage(authController.myUser.value.image!),
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
  );
}

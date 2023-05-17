import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

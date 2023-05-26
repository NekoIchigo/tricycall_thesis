import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: depend_on_referenced_packages, library_prefixes
import 'package:path/path.dart' as Path;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tariff_calculator.dart';
import '../models/user_model.dart';
import '../pages/home_page.dart';
import 'auth_controller.dart';

class PassengerController extends GetxController {
  AuthController authController = Get.find<AuthController>();
  RxBool isProfileUploading = false.obs;
  // ignore: prefer_typing_uninitialized_variables
  var bookingInfo;
  RxBool isLocationsSet = false.obs;
  var bookingId = "".obs;

  changeLocationSet(value) {
    isLocationsSet(value);
  }

  uploadImage(File image) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);
    var reference = FirebaseStorage.instance
        .ref()
        .child('users/$fileName'); // Modify this path/string as your need
    UploadTask uploadTask = reference.putFile(image);
    debugPrint(uploadTask.toString());
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then(
      (value) {
        imageUrl = value;
        debugPrint("Download URL: $value");
      },
    );

    return imageUrl;
  }

  storeUserInfo(
    File? selectedImage,
    String firstName,
    String lastName,
    String email,
    String emergencyEmail,
    String home,
    String work, {
    String? url = '',
  }) async {
    String urlNew = url ?? "";
    if (selectedImage != null) {
      urlNew = await uploadImage(selectedImage);
    }
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String uid = localStorage.getString("user_uid")!;
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'image': urlNew,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'role': 'passenger',
      'emergency_email': emergencyEmail,
      'home_address': home,
      'work_address': work,
    }, SetOptions(merge: true)).then((value) {
      isProfileUploading(false);

      Get.to(() => const HomePage());
    });
  }

  var myUser = UserModel().obs;

  getUserInfo() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((event) {
      myUser.value = UserModel.fromJson(event.data()!);
    });
  }

  storeBookingInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString("user_uid") ?? "";
    String paymentMethod = localStorage.getString("payment_method") ?? "CASH";
    String noteToDriver = localStorage.getString("note_to_driver") ?? "";
    String sourceLocation = localStorage.getString("source")!;
    String destination = localStorage.getString("destination")!;
    String totalDistance = localStorage.getString("total_distance")!;
    double travelPrice = localStorage.getDouble("travel_price")!;

    LatLng sourceLatLng =
        await authController.buildLatLngFromAddress(sourceLocation);
    LatLng destinationLatLng =
        await authController.buildLatLngFromAddress(destination);

    var docRef = FirebaseFirestore.instance.collection("bookings").doc();
    var docId = docRef.id;

    bookingId(docId);

    docRef.set({
      'user_id': userId,
      'driver_id': '',
      'payment_method': paymentMethod,
      'trip_distance': totalDistance,
      'price': travelPrice,
      'note_to_driver': noteToDriver,
      'pick_up_location':
          GeoPoint(sourceLatLng.latitude, sourceLatLng.longitude),
      'drop_off_location':
          GeoPoint(destinationLatLng.latitude, destinationLatLng.longitude),
      'pick_up_text': sourceLocation,
      'drop_off_text': destination,
      'status': 'ongoing' // ongoing, cancelled, finish
    }, SetOptions(merge: true)).then((value) {
      // isProfileUploading(false);

      // Get.to(() => const HomePage());
    });
  }
}

// this query gets a stream of user records and deserialize it 
// to a stream of UserRecord object 

/*
  FirebaseFirestore.instance.collection('users')
    .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    .snapshots()
    .map((e) =>
        UserRecord.fromJson(e.docs.first.data() as Map<String, dynamic>))
*/

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

// ignore: depend_on_referenced_packages, library_prefixes
import 'package:path/path.dart' as Path;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../pages/home_page.dart';

class DriverController extends GetxController {
  var isProfileUploading = false.obs;
  var isDriverOnline = false.obs;
  var isDriverBooked = false.obs;
  var isPickUp = false.obs;
  var bookingId = "".obs;
  var bookingInfo = BookingModel().obs;
  var chatId = "".obs;

  // User token

  uploadImage(File image) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);
    Reference reference;
    reference = FirebaseStorage.instance.ref().child(
        'users/drivers/$fileName'); // Modify this path/string as your need
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then(
      (value) {
        imageUrl = value;
        debugPrint("Download URL: $value");
      },
    );

    return imageUrl;
  }

  storeDriverApplication(
    firstName,
    lastName,
    mobileNumber,
    email,
    operatorName,
    bodyNumber,
    licenseFile,
    tricycleFile,
  ) async {
    if (licenseFile != null && tricycleFile != null) {
      licenseFile = await uploadImage(licenseFile);
      tricycleFile = await uploadImage(tricycleFile);
    }
    FirebaseFirestore.instance.collection('driver_application').doc().set({
      'first_name': firstName,
      'last_name': lastName,
      'mobile_number': mobileNumber,
      'email': email,
      'operator_name': operatorName,
      'body_number': bodyNumber,
      'license_url': licenseFile,
      'tricycle_pic_url': tricycleFile,
      'status': "ongoing", // rejected, ongoing, accepted, cancelled
    }, SetOptions(merge: true)).then((value) {
      isProfileUploading(false);

      // Get.to(() => const HomePage());
    });
  }

  storeDriverInfo(
    File? selectedImage,
    String firstName,
    String lastName,
    String email,
    String emergencyEmail, {
    String? url = '',
  }) async {
    String urlNew = url ?? "";
    if (selectedImage != null) {
      urlNew = await uploadImage(selectedImage);
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'image': urlNew,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'role': 'driver',
      'emergency_email': emergencyEmail,
    }, SetOptions(merge: true)).then((value) {
      isProfileUploading(false);

      Get.to(() => const HomePage());
    });
  }

  var myUser = UserModel().obs;

  getDriverInfo() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((event) {
      myUser.value = UserModel.fromJson(event.data()!);
    });
  }

  updateBookingStatus(String bookingId, String status) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({
      'status': status,
      // 'status': status // waiting, ongoing, cancelled, payment, finish
    });
  }

  initDriverStatus(String token, Position location, String userId) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    bool? isInit = localStorage.getBool("isDriverInit");
    if (isInit!) return; //if not firsttime opening the app

    Timestamp currentTimestamp = Timestamp.now();

    await FirebaseFirestore.instance
        .collection('driver_status')
        .doc(userId)
        .set({
      'latitude': location.latitude,
      'longitude': location.longitude,
      'token': token,
      'status': 'offline', // offline, online, booked
      'availability_timestamp': currentTimestamp,
    });
    Get.snackbar(
      "Welcome Driver!",
      "Go online to start getting bookings",
      backgroundColor: Colors.green.shade300,
    );
    localStorage.setBool("isDriverInit", true);
  }

  updateStatus(String status, String userId) async {
    Timestamp currentTimestamp = Timestamp.now();
    await FirebaseFirestore.instance
        .collection('driver_status')
        .doc(userId)
        .update({
      'status': status, // 'status': status // offline, online, booked
      'availability_timestamp': currentTimestamp,
    });
  }

  initChatCollection() async {
    var chatDoc = FirebaseFirestore.instance.collection("chats").doc();
    chatId(chatDoc.id); // RxString chatId value update with the created chat;

    // Create the chat document with user_id and driver_id fields
    await chatDoc.set({
      'user_id': bookingInfo.value.userId,
      'driver_id': bookingInfo.value.driverId,
    });

    // Create the messages subcollection within the chat document
    var messagesCollection = chatDoc.collection("messages");
    // Create an initial empty document to ensure the 'messages' subcollection exists
    await messagesCollection.doc().set({});
  }

// Make an HTTP POST request to the Cloud Function endpoint
  Future<void> sendDriverResponse(
      String driverId, String bookingId, String response) async {
    final callable = FirebaseFunctions.instance.httpsCallable('driverResponse');
    debugPrint(
        "driverId: $driverId, bookingId: $bookingId, response: $response");

    try {
      final result = await callable.call({
        'driverId': driverId,
        'bookingId': bookingId,
        'response': response,
      });

      // Handle the result if needed
      final data = result.data;
      debugPrint('Driver response sent successfully, $data');
    } catch (error) {
      debugPrint('Error sending driver response: $error');
    }
  }
}

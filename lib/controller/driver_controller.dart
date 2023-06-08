import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

// ignore: depend_on_referenced_packages, library_prefixes
import 'package:path/path.dart' as Path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricycall_thesis/pages/driver/driver_home_page.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../pages/driver/verification_notice_page.dart';
import '../pages/otp_verification_page.dart';

class DriverController extends GetxController {
  var isProfileUploading = false.obs;
  var isDriverOnline = false.obs;
  var isDriverBooked = false.obs;
  var isPickUp = false.obs;
  var bookingId = "".obs;
  var bookingInfo = BookingModel().obs;
  var chatId = "".obs;
  var passengerData = UserModel().obs;
  var driverData = DriverModel().obs;
  var pickUpTime = Timestamp.now().obs;
  var dropOffTime = Timestamp.now().obs;

  // User token

  uploadImage(File image, bool isLicense) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);

    String path =
        isLicense ? "driver/license/$fileName" : "driver/tricycle/$fileName";

    var reference = FirebaseStorage.instance
        .ref()
        .child(path); // Modify this path/string as your need
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

  RxBool isApplicationUploading = false.obs;

  storeDriverApplication(
    String firstName,
    String lastName,
    String mobileNumber,
    String email,
    String operatorName,
    String bodyNumber,
    File? licenseFile,
    File? tricycleFile,
  ) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String licenseUrl = "", tricycleUrl = "";
    if (licenseFile != null && tricycleFile != null) {
      licenseUrl = await uploadImage(licenseFile, true);
      tricycleUrl = await uploadImage(tricycleFile, false);
    }
    var docRef =
        FirebaseFirestore.instance.collection('driver_application').doc();

    var docId = docRef.id;
    localStorage.setString("driver_app_id", docId);

    docRef.set({
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': mobileNumber,
      'email': email,
      'operator_name': operatorName,
      'body_number': bodyNumber,
      'license_url': licenseUrl,
      'tricycle_pic_url': tricycleUrl,
      'status': "ongoing", // rejected, ongoing, accepted, cancelled
    }, SetOptions(merge: true)).then((value) {
      isApplicationUploading(false);
      Get.to(() => OtpVerificationPage(phoneNumber: "+63$mobileNumber"));
      // Get.to(() => const VerificationNoticePage());
    });
  }

  getDriverData(userId) async {
    DriverModel? userData;
    var result =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    if (result.exists) {
      userData = DriverModel.fromJson(result.data()!);
    } else {
      Get.snackbar(
        "Driver not found",
        "No Driver found in provided ID",
        backgroundColor: Colors.red.shade200,
      );
    }
    return userData;
  }

  storeDriverInfo(
    File? selectedImage,
    String firstName,
    String lastName,
    String email,
    String operatorName,
    String bodyNumber,
    File? licenseFile,
    File? tricycleFile, {
    String? url = '',
    String? urlLcs = '',
    String? urlTrike = '',
  }) async {
    String licenseUrl = urlLcs ?? "",
        tricycleUrl = urlTrike ?? "",
        urlNew = url ?? "";
    if (selectedImage != null) {
      urlNew = await uploadImage(selectedImage, true);
    }
    if (licenseFile != null) {
      licenseUrl = await uploadImage(licenseFile, true);
    }
    if (tricycleFile != null) {
      tricycleUrl = await uploadImage(tricycleFile, false);
    }
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String uid = localStorage.getString("user_uid")!;
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'image': urlNew,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'operator_name': operatorName,
      'body_number': bodyNumber,
      'license_url': licenseUrl,
      'tricycle_pic_url': tricycleUrl,
    }, SetOptions(merge: true)).then((value) {
      isProfileUploading(false);

      Get.to(() => const DriverHomePage());
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

    await FirebaseFirestore.instance
        .collection("bookings")
        .doc(bookingId.value)
        .update({'chat_id': chatId.value});
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

  /*
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
  } */
}

import 'dart:developer';
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
  RxString passengerId = "".obs;
  RxDouble driverRating = 0.0.obs;
  RxBool isAssignedRoute = false.obs;
  RxBool isUrlLoading = true.obs;
  RxInt travelPrice = 0.obs;
  RxBool travelDiscount = false.obs;

  changeLocationSet(value) {
    isLocationsSet(value);
  }

  uploadImage(File image, bool isProfile) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);

    String path = isProfile
        ? "passenger/profile/$fileName"
        : "passenger/other_files/$fileName";

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

  storeUserInfo(
      File? selectedImage,
      File? discountImage,
      String firstName,
      String lastName,
      // String home,
      // String work,
      String email,
      String contactPerson,
      {String? url = '',
      String? discountUrl = ''}) async {
    String urlNew = url ?? "", newDiscountUrl = discountUrl ?? "";
    if (selectedImage != null) {
      urlNew = await uploadImage(selectedImage, true);
    }
    if (discountImage != null) {
      newDiscountUrl = await uploadImage(discountImage, false);
    }
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var phoneNumber = authController.getPhoneNumber();
    String uid = localStorage.getString("user_uid")!;
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'image': urlNew,
      'discount_image': newDiscountUrl,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'role': 'passenger',
      'contact_person': contactPerson,
      'phone_number': phoneNumber,
      // 'home_address': home,
      // 'work_address': work,
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
    print("discount_url: ${myUser.value.discountImage}");
    if (myUser.value.discountImage != null) {
      travelDiscount(true);
      print("travelDiscount: ${travelDiscount.value}");
    }
  }

  storeBookingInfo(token) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var phoneNumber = authController.getPhoneNumber();
    passengerId.value = localStorage.getString("user_uid")!;
    String paymentMethod = localStorage.getString("payment_method") ?? "CASH";
    String noteToDriver = localStorage.getString("note_to_driver") ?? "";
    String sourceLocation = localStorage.getString("source")!;
    String destination = localStorage.getString("destination")!;
    String totalDistance = localStorage.getString("total_distance")!;
    int travelPrice = localStorage.getInt("travel_price")!;
    int totalPassenger = localStorage.getInt("total_passengers") ?? 1;

    LatLng sourceLatLng =
        await authController.buildLatLngFromAddress(sourceLocation);
    LatLng destinationLatLng =
        await authController.buildLatLngFromAddress(destination);

    var docRef = FirebaseFirestore.instance.collection("bookings").doc();
    var docId = docRef.id;

    bookingId(docId);

    docRef.set({
      'user_id': passengerId.value,
      'driver_id': '',
      'chat_id': '',
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
      'passenger_token': token,
      'phone_number': phoneNumber,
      'total_passenger': totalPassenger,
      'timestamp': Timestamp.now(),
      'status': 'waiting' // waiting, ongoing, cancelled, payment, finish
    }, SetOptions(merge: true)).then((value) {
      // isProfileUploading(false);

      // Get.to(() => const HomePage());
    });
  }

  storeRatings(String bookingUId, String driverId) async {
    var result = FirebaseFirestore.instance.collection("ratings").doc();
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var ratingVal = localStorage.getInt("rating_value");
    var commentVal = localStorage.getString("comment_value");
    // var ratingsId = result.id;
    log("bookingId.value ${bookingId.value}");
    result.set({
      "booking_id": bookingId.value,
      "driver_id": driverId,
      "rating_value": ratingVal,
      "comment_value": commentVal,
    }, SetOptions(merge: true)).then((value) {
      // isProfileUploading(false);

      Get.offAll(() => const HomePage());
    });
  }

  updateBookingStatus(String bookingUId, String status) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingUId)
        .update({
      'status': status,
      // 'status': status // waiting, ongoing, cancelled, payment, finish
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

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: depend_on_referenced_packages, library_prefixes
import 'package:path/path.dart' as Path;
import '../models/user_model.dart';
import '../pages/home_page.dart';

class DriverController extends GetxController {
  var isProfileUploading = false.obs;
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
}

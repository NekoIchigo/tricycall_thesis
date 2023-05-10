import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tricycall_thesis/pages/account_setting_page.dart';
// ignore: depend_on_referenced_packages, library_prefixes
import 'package:path/path.dart' as Path;

import '../pages/home_page.dart';

class AuthController extends GetxController {
  String userUid = "";
  var verId = "";
  int? resendTokenId;
  bool phoneAuthCheck = false;
  dynamic credentials;

  var isProfileUploading = false.obs;

  phoneAuth(String phone) async {
    try {
      credentials = null;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          log('Completed');
          credentials = credential;
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        forceResendingToken: resendTokenId,
        verificationFailed: (FirebaseAuthException e) {
          log('Failed');
          if (e.code == 'invalid-phone-number') {
            debugPrint('The provide phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          log('Code sent');
          verId = verificationId;
          resendTokenId = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationid) {},
      );
    } catch (e) {
      log("Error ocured $e");
    }
  }

  verifyOtp(String otpNumber) async {
    log("Called");
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verId,
      smsCode: otpNumber,
    );
    log("LoggedIn");

    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      decideRoute();
    });
  }

  decideRoute() {
    // Check user Login
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Check is account setting is finish
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value) {
        value.exists
            ? Get.to(() => const HomePage())
            : Get.to(() => const AccountSettingPage());
      });
    }
  }

  uploadImage(File image) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);
    var reference = FirebaseStorage.instance.ref().child('user/$fileName');
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then((value) {
      imageUrl = value;
      // ignore: avoid_print
      print("Download URL: $value");
    });

    return imageUrl;
  }

  storeUserInfo(File selectedImage, String firstName, String lastName,
      String home, String work) async {
    String url = await uploadImage(selectedImage);
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'image': url,
      'first_name': firstName,
      'last_name': lastName,
      'home_address': home,
      'work_address': work,
    }).then((value) {
      isProfileUploading(false);
      Get.to(() => const HomePage());
    });
  }
}

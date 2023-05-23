import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
// ignore: library_prefixes
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricycall_thesis/models/user_model.dart';
// ignore: depend_on_referenced_packages, library_prefixes
import 'package:tricycall_thesis/pages/account_setting_page.dart';

import '../pages/driver/driver_home_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';

class AuthController extends GetxController {
  String userUid = '';
  var verId = '';
  int? resendTokenId;
  dynamic credentials;

  RxList userCards = [].obs;
  bool isLoginAsDriver = false;

  storeUserCard(String number, String expiry, String cvv, String name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cards')
        .add({'name': name, 'number': number, 'cvv': cvv, 'expiry': expiry});

    return true;
  }

  getUserCards() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cards')
        .snapshots()
        .listen((event) {
      userCards.value = event.docs;
    });
  }

  phoneAuth(String phone) async {
    try {
      credentials = null;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(milliseconds: 45000),
        verificationCompleted: (PhoneAuthCredential credential) async {
          log('Completed');
          credentials = credential;
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        codeSent: (String verificationId, int? resendToken) async {
          log('Code sent');
          verId = verificationId;
          resendTokenId = resendToken;
        },
        forceResendingToken: resendTokenId,
        verificationFailed: (FirebaseAuthException e) {
          log('Failed');
          debugPrint("Error Code: ${e.code}");
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      log("Error occured $e");
    }
  }

  verifyOtp(String otpNumber) async {
    log("Called");
    PhoneAuthCredential credential =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: otpNumber);

    log("LogedIn");

    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      decideRoute();
    }).catchError((e) {
      debugPrint("Error while sign In $e");
    });
  }

  var isDecided = false;

  decideRoute() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (isDecided) {
      return;
    }
    isDecided = true;
    debugPrint("called");

    ///step 1- Check user login?
    User? user = FirebaseAuth.instance.currentUser;
    print(user);
    localStorage.setString("user_uid", user?.uid ?? "");

    if (user != null) {
      /// step 2- Check whether user profile exists?

      ///isLoginAsDriver == true means navigate it to the driver module

      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value) {
        // DONE: Fix error if value.exist the userinfo will be taken
        ///isLoginAsDriver == true means navigate it to driver module
        if (value.exists) {
          UserModel userinfo = UserModel.fromJson(value.data()!);
          if (userinfo.role == "driver") {
            Get.offAll(() => const DriverHomePage());
          } else if (userinfo.role == "passenger") {
            Get.offAll(() => const HomePage());
          } else {
            // TODO : Admin Pages
          }
        } else {
          Get.offAll(() => const AccountSettingPage());
        }
      }).catchError((e) {
        debugPrint("Error while decideRoute is $e");
      });
    } else {
      Get.to(() => const LoginPage());
    }
  }

  Future<Prediction?> showGoogleAutoComplete(BuildContext context) async {
    Prediction? p = await PlacesAutocomplete.show(
      offset: 0,
      radius: 1000,
      strictbounds: false,
      region: "ph",
      language: "en",
      context: context,
      mode: Mode.overlay,
      apiKey: "AIzaSyBFPJ9b4hwLh_CwUAPEe8aMIGT4deavGCk",
      components: [Component(Component.country, "ph")],
      types: [],
      hint: "Search City",
    );

    return p;
  }

  Future<LatLng> buildLatLngFromAddress(String place) async {
    List<geoCoding.Location> locations =
        await geoCoding.locationFromAddress(place);
    return LatLng(locations.first.latitude, locations.first.longitude);
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => const LoginPage());
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint(user.toString());
    }
  }
}

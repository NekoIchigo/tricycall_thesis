import 'dart:math' show cos, sqrt, asin;
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
// ignore: library_prefixes
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricycall_thesis/models/user_model.dart';
// ignore: depend_on_referenced_packages, library_prefixes
import 'package:tricycall_thesis/pages/account_setting_page.dart';

import '../pages/driver/driver_home_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';

class AuthController extends GetxController {
  String verId = '';
  int? resendTokenId;
  dynamic credentials;
  String? messagingToken;
  RxString userUID = "".obs;

  Rx<BitmapDescriptor> sourceIcon = BitmapDescriptor.defaultMarker.obs,
      destinationIcon = BitmapDescriptor.defaultMarker.obs,
      driversIcon = BitmapDescriptor.defaultMarker.obs;

  void setCustomMarkerIcon() async {
    final Uint8List source =
        await getBytesFromAsset('assets/images/source_icon.png', 50);
    sourceIcon(BitmapDescriptor.fromBytes(source));
    final Uint8List destination =
        await getBytesFromAsset('assets/images/destination_icon.png', 50);
    destinationIcon(BitmapDescriptor.fromBytes(destination));
    final Uint8List driverIcon =
        await getBytesFromAsset('assets/images/tricycle_icon.png', 50);
    driversIcon(BitmapDescriptor.fromBytes(driverIcon));
  }

  getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    messagingToken = await FirebaseMessaging.instance.getToken();
    if (messagingToken == null) return false;
    localStorage.setString("messaging_token", messagingToken!);
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
          log("Error Code: ${e.code}");
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      log("Error occured $e");
    }
  }

  getPhoneNumber() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.phoneNumber != null) {
      String phoneNumber = user.phoneNumber!;
      return phoneNumber;
    } else {
      Get.snackbar('Error', 'Phone number not available');
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
  var isRegistered = true.obs;

  decideRoute() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (isDecided) {
      return;
    }
    isDecided = true;
    debugPrint("called");

    User? user = FirebaseAuth.instance.currentUser;
    localStorage.setString("user_uid", user?.uid ?? "");

    if (user != null) {
      userUID(user.uid);
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value) {
        if (value.exists) {
          UserModel userinfo = UserModel.fromJson(value.data()!);
          if (userinfo.role == "driver") {
            Get.offAll(() => const DriverHomePage());
          } else if (userinfo.role == "passenger") {
            Get.offAll(() => const HomePage());
          }
        } else {
          isRegistered(false);
          Get.offAll(() => const AccountSettingPage());
        }
      }).catchError((e) {
        debugPrint("Error while decideRoute is $e");
      });
    } else {
      Get.to(() => const LoginPage());
    }
  }

  signOut() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    localStorage.setString("payment_method", "CASH");
    localStorage.setString("note_to_driver", "");
    localStorage.setString("source", "");
    localStorage.setString("destination", "");
    localStorage.setString("total_distance", "");
    localStorage.setDouble("travel_price", 0.0);
    localStorage.setBool("isDriverInit", false);

    await FirebaseAuth.instance.signOut();
    Get.offAll(() => const LoginPage());
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint(user.toString());
    }
  }

  // ------------------------------------------- CLOUD FUNCTIONS -------------------------------
  // Create an instance of CloudFunctions
  final cloudFunctions = FirebaseFunctions.instance;

// Call the Cloud Function
  Future<void> sendEmailNotification(
    String receiverEmail,
    String receiverName,
    String userName,
    String location,
    double lat,
    double lng,
    String driverName,
    Timestamp pickUpTime,
    Timestamp dropOffTime,
  ) async {
    // Convert Timestamp to DateTime
    DateTime res = pickUpTime.toDate();
    String formattedpickUpTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(res);

    DateTime res1 = dropOffTime.toDate();
    String formatteddropOffTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(res1);

    final dynamic data = {
      'receiverEmail': receiverEmail,
      'receiverName': receiverName,
      'userName': userName,
      'location': location,
      'lat': lat,
      'lng': lng,
      'driverName': driverName,
      'pickUpTime': formattedpickUpTime,
      'dropoffTime': formatteddropOffTime,
    };
    log("Function Called");
    try {
      // Make the HTTP request to the Cloud Function
      final HttpsCallable callable =
          cloudFunctions.httpsCallable('sendEmailNotification');
      await callable.call(data);
      log('Email notification sent successfully');
    } catch (error) {
      log('Error sending email notification: $error');
    }
  }

  // ------------------------------------------- UNIVERSAL FUNCTIONS -------------------------------
  getCurrentUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user!.uid;
  }

  getUserData(String userId) async {
    UserModel? userData;
    var result =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    if (result.exists) {
      print(result.data()!);
      userData = UserModel.fromJson(result.data()!);
    } else {
      Get.snackbar(
        "User not found",
        "No user found in provided ID",
        backgroundColor: Colors.red.shade200,
      );
    }
    return userData;
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Permission Error",
          "Location services are disabled. Please enable the services");

      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Permission Error", "Location permissions are denied");

        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Permission Error",
          "Location permissions are permanently denied, we cannot request permissions.");

      return false;
    }
    return true;
  }

  Future<LatLng> buildLatLngFromAddress(String place) async {
    List<geoCoding.Location> locations =
        await geoCoding.locationFromAddress(place);
    // print("getlatlng = $place");
    return LatLng(locations.first.latitude, locations.first.longitude);
  }

  addMessageToChat(String chatId, String senderId, String content) async {
    var chatDoc = FirebaseFirestore.instance.collection("chats").doc(chatId);
    var messagesCollection = chatDoc.collection("messages");

    await messagesCollection.add({
      'sender_id': senderId,
      'content': content,
      'timestamp': Timestamp.now(),
    });
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
      apiKey: "AIzaSyCbYWT5IPpryxcCqNmO_4EyFFCpIejPBf8",
      components: [Component(Component.country, "ph")],
      types: [],
      hint: "Search City",
    );

    return p;
  }

  double coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  showErrorDialog(String title, String errorMsg, Function confirm) {
    Get.defaultDialog(
      title: title,
      titleStyle:
          GoogleFonts.varelaRound(fontSize: 16, fontWeight: FontWeight.bold),
      content: Text(
        errorMsg,
        style:
            GoogleFonts.varelaRound(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          confirm();
        },
        child: Text(
          "Confirm",
          style: GoogleFonts.varelaRound(
              fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /*
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
  */
}

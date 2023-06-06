import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tricycall_thesis/pages/driver_found_page.dart';
import 'package:tricycall_thesis/pages/home_page.dart';

import '../pages/driver/booking_found_page.dart';
import '../widgets/webview.dart';

class NotificationController extends GetxController {
  // <---------------------------------- Handles Receiving of notification
  // create firebase messaging instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  var bookingId = "".obs;
  var driverId = "".obs;
  var hint = "".obs;

  String? get fcmToken => _fcmToken;

  updateBookingId(String? id) {
    bookingId(id);
  }

  updateDriverId(String? id) {
    driverId(id);
  }

  @override
  void onInit() {
    super.onInit();

    // Configure Firebase Messaging
    _configureFirebaseMessaging();
    _registerFCMToken();
  }

  Future<void> _registerFCMToken() async {
    // Request permission for receiving notifications
    await _firebaseMessaging.requestPermission();

    // Get the FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('Refreshed FCM Token: $newToken');
      // Send the new token to your server for updating the driver's FCM token
    });
  }

  void _configureFirebaseMessaging() {
    // Request permission for receiving notifications (optional)
    _firebaseMessaging.requestPermission();

    // Configure the message handler for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the incoming notification message
      _handleMessage(message);
    });

    // Configure the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleMessage(RemoteMessage message) {
    // Extract the notification data
    final notification = message.notification;
    final data = message.data;
    var user = "";

    // Handle the notification and data
    if (notification != null) {
      // Handle the notification title, body, etc.
      final title = notification.title;
      final body = notification.body;

      Get.snackbar(
        title!,
        body!,
        backgroundColor: Colors.green.shade300,
      );
    }

    if (data.isNotEmpty) {
      // Handle the custom data payload
      // Access the data fields using the data map

      user = data['user'];

      // Do something with the booking data
      // For example, update app state or perform a specific action based on the data
      if (user == "driver") {
        final bookingData = data['bookingData'];
        Get.to(() => const BookFoundPage());
        // Get.snackbar("Booking Data", bookingData.toString());

        updateBookingId(bookingData);
      } else if (user == "passenger") {
        var driverID = data['driverId'];
        hint(data['hint']);
        if (data['hint'] == "arrive_at_destination_gcash") {
          Get.to(() => const WebViewScreen(
                url:
                    'https://pm.link/org-FSjssrznvGpyUWue7JPNkB1g/test/EqQ3Wh4',
              ));
          ratingDialog();
        } else if (data['hint'] == "arrive_at_destination_cash") {
          ratingDialog();
        } else if (data['hint'] == "transaction_complete") {
          Get.to(() => const HomePage());
          return;
        }
        Get.to(() => const DriverFoundPage());
        updateDriverId(driverID);
      }
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    _handleMessage(message);
  }

  // <------------------------------------- Handles Sending of Notification ---------------------------------------------->

  // Server key from Firebase Console > Project Settings > Cloud Messaging
  final String serverKey =
      'AAAAdSsHtYs:APA91bHD0EW_KWDYQ-_jRt-xAsR93g8C8e7A2J8c8M1b0IHmVIc-8BOnprduYNQTnL2H_Sz2gZq1z1ZMJYETsy2KQqtWDNdr7fR41ontyHR9rZfTyF5zHPKWzlgykqbSL23IvyUlyffi';

  // Firebase Cloud Messaging endpoint
  final String fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

  Future<void> sendNotification(
      driverId, passengerToken, String title, String body, String hint) async {
    // Define your notification payload
    final Map<String, dynamic> notification = {
      'title': title,
      'body': body,
    };

    // Define the message data payload
    final Map<String, dynamic> data = {
      'user': 'passenger',
      'driverId': driverId,
      'hint': hint,
    };

    // Define the FCM message
    final Map<String, dynamic> fcmMessage = {
      'notification': notification,
      'data': data,
      'priority': 'high',
      'to': passengerToken, // or 'token': 'DEVICE_TOKEN' for specific device
    };

    // Convert the FCM message to JSON format
    final String fcmMessageJson = jsonEncode(fcmMessage);

    // Create the HTTP headers
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    try {
      // Send the HTTP POST request to the FCM endpoint
      final http.Response response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: headers,
        body: fcmMessageJson,
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully');
      } else {
        debugPrint('Failed to send notification. Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  ratingDialog() {
    Get.defaultDialog(
      title: "ALREADY ARRIVED TO YOUR DESTINATION",
      titleStyle: GoogleFonts.varelaRound(
        fontSize: 18,
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
      titlePadding: const EdgeInsets.all(20),
      content: RatingContent(
        bookindId: bookingId.value,
        driverId: driverId.value,
      ),
    );
  }
}

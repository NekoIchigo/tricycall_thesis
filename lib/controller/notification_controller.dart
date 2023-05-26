import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../pages/driver/booking_found_page.dart';

class NotificationController extends GetxController {
  // create firebase messaging instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  var bookingId = "".obs;

  String? get fcmToken => _fcmToken;

  updateBookingId(String? id) {
    bookingId(id);
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
    print('FCM Token: $_fcmToken');

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('Refreshed FCM Token: $newToken');
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

    // Handle the notification and data
    if (notification != null) {
      // Handle the notification title, body, etc.
      final title = notification.title;
      final body = notification.body;

      // Do something with the notification
      // For example, show a local notification or update app state
      // You can use packages like flutter_local_notifications for local notifications
      Get.snackbar(title!, body!);
      // Print the notification details for debugging-
    }

    if (data.isNotEmpty) {
      // Handle the custom data payload
      // Access the data fields using the data map
      final bookingData = data['bookingData'];

      // Do something with the booking data
      // For example, update app state or perform a specific action based on the data
      Get.to(() => const BookFoundPage());
      Get.snackbar("Booking Data", bookingData.toString());

      updateBookingId(bookingData);
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    _handleMessage(message);
  }
}

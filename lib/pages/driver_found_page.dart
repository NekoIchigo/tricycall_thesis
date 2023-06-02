import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricycall_thesis/controller/driver_controller.dart';
import 'package:tricycall_thesis/pages/home_page.dart';

import '../controller/notification_controller.dart';
import '../controller/passenger_controller.dart';
import '../models/booking_model.dart';
import '../widgets/drawer.dart';
import 'chat_page.dart';

class DriverFoundPage extends StatefulWidget {
  const DriverFoundPage({super.key});

  @override
  State<DriverFoundPage> createState() => _DriverFoundPageState();
}

class _DriverFoundPageState extends State<DriverFoundPage> {
  final googleApiKey = "AIzaSyB7S43VLk2wDGlm6gxewv8lwu2FZy-SZzY";

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  PassengerController passengerController = Get.find<PassengerController>();
  DriverController driverController = Get.find<DriverController>();
  NotificationController notificationController =
      Get.find<NotificationController>();

  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  Position? _currentLocation;
  Set<Marker> markers = <Marker>{};
  String driverIdFromBooking = "";

  late BookingModel bookingInfo;

  Future<void> _getCurrentPosition() async {
    final hasPermission = await authController.handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentLocation = position;
      });
    }).catchError((e) {
      debugPrint(e);
    });
    // print(_currentLocation);
  }

  centerCamera() async {
    GoogleMapController googleMapController = await _controller.future;

    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 16,
          target: LatLng(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          ),
        ),
      ),
    );
    setState(() {});
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    GoogleMapController googleMapController = await _controller.future;

    await googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              snapshot.data!.docs
                  .singleWhere((element) => element.id == "user1")['latitude'],
              snapshot.data!.docs
                  .singleWhere((element) => element.id == "user1")['longitude'],
            ),
            zoom: 14.47)));
  }

  getDriverIdFromBooking() async {
    var id = passengerController.bookingId.value;

    var bookingData =
        await FirebaseFirestore.instance.collection('bookings').doc(id).get();

    if (bookingData.exists) {
      driverIdFromBooking = bookingData.data()!['driver_id'];
      bookingInfo = BookingModel.fromJson(bookingData.data()!);
    }
  }

  PolylinePoints polylinePoints = PolylinePoints();

  Future<List<LatLng>> getPolylinePoints(
      LatLng sourceLocation, LatLng destination) async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    return polylineCoordinates;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    centerCamera();
    getDriverIdFromBooking();
  }

  bool isPolylineCleared = false;

  @override
  Widget build(BuildContext context) {
    if (notificationController.hint.value == "arrive_at_destination") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ratingDialog(); //TODO: check if this works
      }); // TODO : if payment is gcash show gcash payment dialog
    }
    return Scaffold(
      drawer: buildDrawer(),
      key: scaffoldState,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('driver_status')
            .doc(notificationController.driverId.value
                .toString()) // Replace 'driverIdFromBooking' with the actual driver ID
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final driverStatus = snapshot.data;

          if (driverStatus == null || !driverStatus.exists) {
            return const Text('Driver not found');
          }

          final driverData = driverStatus.data() as Map<String, dynamic>;
          final driverLocation = LatLng(
            driverData['latitude'] as double? ?? 0.0,
            driverData['longitude'] as double? ?? 0.0,
          );

          final destination = bookingInfo.destinaiton;
          final sourceLoc = bookingInfo.sourceLoc;

          if (notificationController.hint.value == "trip_start") {
            if (!isPolylineCleared) polylineCoordinates.clear();
            isPolylineCleared = true;
            getPolylinePoints(driverLocation, destination!)
                .then((List<LatLng> points) {
              markers.add(
                Marker(
                  markerId: const MarkerId('destination'),
                  position: destination,
                  icon: authController.destinationIcon.value,
                ),
              );
              setState(() {
                polylineCoordinates = points;
              });
            });
          } else {
            getPolylinePoints(driverLocation, sourceLoc!)
                .then((List<LatLng> points) {
              markers.add(
                Marker(
                  markerId: const MarkerId('destination'),
                  position: sourceLoc,
                  icon: authController.destinationIcon.value,
                ),
              );
              setState(() {
                polylineCoordinates = points;
              });
            });
          }

          markers.add(
            Marker(
              markerId: const MarkerId('driver'),
              position: driverLocation,
              icon: authController.driversIcon.value,
            ),
          );

          return SizedBox(
            height: Get.height,
            width: Get.width,
            child: SafeArea(
              child: Stack(
                children: [
                  _currentLocation != null
                      ? GoogleMap(
                          compassEnabled: false,
                          tiltGesturesEnabled: false,
                          zoomControlsEnabled: false,
                          zoomGesturesEnabled: false,
                          myLocationButtonEnabled: false,
                          onMapCreated: (mapContorller) {
                            _controller.complete(mapContorller);
                          },
                          initialCameraPosition: CameraPosition(
                            target: LatLng(_currentLocation!.latitude,
                                _currentLocation!.longitude),
                            zoom: 15,
                          ),
                          polylines: {
                            Polyline(
                              polylineId: const PolylineId("route"),
                              points: polylineCoordinates,
                              color: Colors.red,
                              width: 3,
                            ),
                          },
                          markers: markers,
                        )
                      : const CircularProgressIndicator(),
                  Positioned(
                    top: 10,
                    left: 20,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          scaffoldState.currentState?.openDrawer();
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 20,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon: const Icon(Icons.chat, color: Colors.white),
                        onPressed: () {
                          Get.to(() => const ChatPage());
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 20,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon:
                            const Icon(Icons.my_location, color: Colors.white),
                        onPressed: () {
                          centerCamera();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  paymentDialog() {
    Get.defaultDialog(
        title: "Gcash Payment",
        content: Column(
          // TODO: implement gcash payment
          children: const [],
        ));
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
      content: Column(
        children: [
          Text(
            "RATE YOUR DRIVER",
            style: GoogleFonts.varelaRound(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const RatingSection(),
          const SizedBox(height: 20),
          Image.asset(
            "assets/images/sided_tricycle.png",
            width: 100,
            fit: BoxFit.cover,
          ),
          Container(
            height: 3,
            width: Get.width,
            color: Colors.green.shade900,
          )
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          localStorage.setString("payment_method", "CASH");
          localStorage.setString("note_to_driver", "");
          localStorage.setString("source", "");
          localStorage.setString("destination", "");
          localStorage.setString("total_distance", "");
          localStorage.setDouble("travel_price", 0.0);
          Get.to(() => const HomePage());
        },
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
        child: Text(
          "Confirm",
          style: GoogleFonts.varelaRound(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class RatingSection extends StatefulWidget {
  const RatingSection({super.key});

  @override
  State<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<RatingSection> {
  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: 5,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        // print(rating);
      },
    );
  }
}

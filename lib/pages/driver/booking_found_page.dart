import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:tricycall_thesis/controller/driver_controller.dart';

import '../../controller/auth_controller.dart';
import '../../controller/notification_controller.dart';
import '../../models/booking_model.dart';
import 'driver_drawer.dart';
import 'driver_home_page.dart';

class BookFoundPage extends StatefulWidget {
  const BookFoundPage({super.key});

  @override
  State<BookFoundPage> createState() => _BookFoundPageState();
}

class _BookFoundPageState extends State<BookFoundPage> {
  final googleApiKey = "AIzaSyCbYWT5IPpryxcCqNmO_4EyFFCpIejPBf8";
  AuthController authController = Get.find<AuthController>();
  final Completer<GoogleMapController> _controller = Completer();
  NotificationController notificationController =
      Get.find<NotificationController>();
  DriverController driverController = Get.find<DriverController>();

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  Position? _currentLocation;

  final CountdownController _controllerTimer =
      CountdownController(autoStart: true);

  List<LatLng> polylineCoordinates = [];
  Set<Marker> markers = <Marker>{};
  Map<PolylineId, Polyline> polylines = {};

  bool isLoading = false;

  Future<void> _getCurrentPosition() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentLocation = position;
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void getPolyPoints(sourceLocation, destination) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    // print("polylineres = $result");
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
      // Defining an ID
      PolylineId id = const PolylineId('poly');

      // Initializing Polyline
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 3,
      );

      // Adding the polyline to the map
      polylines[id] = polyline;
      setState(() {});
    }
  }

  getBookingData() async {
    driverController.bookingId.value = notificationController.bookingId.value;
    var bookingSnapshot = await FirebaseFirestore.instance
        .collection("bookings")
        .doc(driverController.bookingId.value.toString())
        .get();

    // Get.snackbar("Booking ID", bookingId);
    if (bookingSnapshot.exists) {
      driverController.bookingInfo.value =
          BookingModel.fromJson(bookingSnapshot.data()!);

      setState(() {
        markers.add(Marker(
          markerId: const MarkerId("source"),
          icon: authController.sourceIcon.value,
          position: LatLng(
            driverController.bookingInfo.value.sourceLoc!.latitude,
            driverController.bookingInfo.value.sourceLoc!.longitude,
          ),
          infoWindow: const InfoWindow(title: "Passenger pick up location"),
        ));

        markers.add(Marker(
          markerId: const MarkerId("destination"),
          icon: authController.destinationIcon.value,
          position: LatLng(
            driverController.bookingInfo.value.destinaiton!.latitude,
            driverController.bookingInfo.value.destinaiton!.longitude,
          ),
          infoWindow: const InfoWindow(title: "Passenger drop off location"),
        ));
        getPolyPoints(
          driverController.bookingInfo.value.sourceLoc,
          driverController.bookingInfo.value.destinaiton,
        );
      });
    }
  }

  @override
  initState() {
    super.initState();
    _getCurrentPosition();
    // getPaymentMethod();
    getBookingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      drawer: driverDrawer(),
      body: SingleChildScrollView(
        child: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Column(
            children: [
              _currentLocation == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                      ),
                    )
                  : GestureDetector(
                      behavior:
                          HitTestBehavior.opaque, // Absorb the scroll gestures
                      child: SizedBox(
                        height: Get.height * .60,
                        child: googleMap(),
                      ),
                    ),
              Container(
                height: Get.height * .18,
                width: Get.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: informationDetails(),
              ),
              Container(
                height: Get.height * .22,
                width: Get.width,
                decoration: const BoxDecoration(
                  color: Color(0xFFE7FFF4),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : interactionSection(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget informationDetails() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          "New booking",
          style: GoogleFonts.varelaRound(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                width: Get.width * .10,
                height: 70,
                child: leftLocationIcons(),
              ),
              const SizedBox(width: 5),
              fieldSourceDestination(),
            ],
          ),
        ),
      ],
    );
  }

  Column fieldSourceDestination() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            width: Get.width * .75,
            child: Text.rich(
              TextSpan(
                text: driverController.bookingInfo.value.sourceText ?? "",
                style: GoogleFonts.varelaRound(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            width: Get.width * .75,
            child: Text.rich(
              TextSpan(
                text: driverController.bookingInfo.value.destinationText ?? "",
                style: GoogleFonts.varelaRound(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Stack leftLocationIcons() {
    return Stack(
      children: [
        Positioned(
          top: 5,
          left: 20,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 22.5,
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
          ),
        ),
        Positioned(
          top: 35,
          left: 22.5,
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
          ),
        ),
        const Positioned(
          bottom: 0,
          left: 13,
          child: Icon(
            Icons.location_on,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget interactionSection() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                Get.defaultDialog(
                  title: "Notes from Passenger:",
                  titleStyle: GoogleFonts.varelaRound(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  titlePadding: const EdgeInsets.symmetric(vertical: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  content: Container(
                    padding: const EdgeInsets.all(10.0),
                    height: Get.height * .1,
                    width: Get.width,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      driverController.bookingInfo.value.notes ?? "",
                      style: GoogleFonts.varelaRound(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  confirm: Container(
                    width: Get.width,
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: const Text("Okay"),
                    ),
                  ),
                );
              },
              child: Text(
                "Notes from Passenger",
                style: GoogleFonts.varelaRound(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: Get.width * .10,
                  color: Colors.green,
                ),
                Text(
                  "${driverController.bookingInfo.value.totalPassnger} Passengers",
                  style: GoogleFonts.varelaRound(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Image.asset(
              "assets/images/peso_icon.png",
              width: 20,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 5),
            Text(
              "${driverController.bookingInfo.value.price}",
              style: GoogleFonts.varelaRound(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: OutlinedButton(
            onPressed: () async {
              isLoading = true;
              try {
                driverController.isDriverBooked.value = true;
                await notificationController.sendNotification(
                  driverController.bookingInfo.value.driverId,
                  driverController.bookingInfo.value.passengerToken,
                  "Driver Found",
                  "The Driver is on his way to pick you up",
                  "driver_found",
                );
                driverController.updateBookingStatus(
                  driverController.bookingId.value,
                  "ongoing",
                );
                driverController.initChatCollection();
                isLoading = false;
                Get.to(() => const DriverHomePage());
              } catch (error) {
                isLoading = false;
                authController.showErrorDialog("Error", "Something went wrong",
                    () {}); // TODO: update driver to online then return to driver home
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              backgroundColor: Colors.white,
            ),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                Text(
                  "Accept",
                  style: GoogleFonts.varelaRound(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Expanded(child: SizedBox()),
                CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.green,
                    child: Countdown(
                      controller: _controllerTimer,
                      seconds: 60,
                      build: (BuildContext context, double time) {
                        return Text(time.toStringAsFixed(0),
                            style: GoogleFonts.varelaRound(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ));
                      },
                      interval: const Duration(seconds: 1),
                      onFinished: () {
                        if (driverController.isDriverBooked.value) {
                          return;
                        }
                        log("timer done declined");
                        driverController.sendDriverResponse(
                          driverController.bookingInfo.value.driverId!,
                          driverController.bookingId.value,
                          "declined",
                        );
                        Get.to(() => const DriverHomePage());
                        setState(() {});
                      },
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: OutlinedButton(
            onPressed: () {
              driverController.sendDriverResponse(
                driverController.bookingInfo.value.driverId!,
                driverController.bookingId.value,
                "declined",
              );
              Get.to(() => const DriverHomePage());
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              backgroundColor: Colors.white,
            ),
            child: Text(
              "Decline",
              style: GoogleFonts.varelaRound(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget googleMap() {
    return SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            compassEnabled: false,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false,
            myLocationEnabled: true,
            onMapCreated: (mapContorller) {
              _controller.complete(mapContorller);
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  _currentLocation!.latitude, _currentLocation!.longitude),
              zoom: 15,
            ),
            polylines: Set<Polyline>.of(polylines.values),
            markers: markers,
          ),
          Positioned(
            top: 50,
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
        ],
      ),
    );
  }
}

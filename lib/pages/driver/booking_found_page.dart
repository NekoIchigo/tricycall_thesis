import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tricycall_thesis/controller/driver_controller.dart';

import '../../controller/auth_controller.dart';
import '../../controller/notification_controller.dart';
import 'driver_drawer.dart';

class BookFoundPage extends StatefulWidget {
  const BookFoundPage({super.key});

  @override
  State<BookFoundPage> createState() => _BookFoundPageState();
}

// TODO : Draw polyline
class _BookFoundPageState extends State<BookFoundPage> {
  final googleApiKey = "AIzaSyBFPJ9b4hwLh_CwUAPEe8aMIGT4deavGCk";
  AuthController authController = Get.find<AuthController>();
  final Completer<GoogleMapController> _controller = Completer();
  NotificationController notificationController =
      Get.find<NotificationController>();
  DriverController driverController = Get.find<DriverController>();

  String userUid = "", bookingId = "";
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  Position? _currentLocation;
  String sourceText = "", destinationText = "", notesFromPassenger = "";
  // ignore: prefer_typing_uninitialized_variables
  var price;

  List<LatLng> polylineCoordinates = [];
  Set<Marker> markers = <Marker>{};

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker,
      destinationIcon = BitmapDescriptor.defaultMarker,
      currentLocIcon = BitmapDescriptor.defaultMarker;

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

  void setCustomMarkerIcon() async {
    final Uint8List source = await authController.getBytesFromAsset(
        'assets/images/source_icon.png', 50);
    sourceIcon = BitmapDescriptor.fromBytes(source);
    final Uint8List destination = await authController.getBytesFromAsset(
        'assets/images/destination_icon.png', 50);
    destinationIcon = BitmapDescriptor.fromBytes(destination);
    final Uint8List currentIcon = await authController.getBytesFromAsset(
        'assets/images/tricycle_icon.png', 80);
    currentLocIcon = BitmapDescriptor.fromBytes(currentIcon);
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
      setState(() {});
    }
  }

  getBookingData() async {
    bookingId = notificationController.bookingId.value;
    var bookingSnapshot = await FirebaseFirestore.instance
        .collection("bookings")
        .doc(bookingId.toString())
        .get();

    Get.snackbar("Booking ID", bookingId);
    if (bookingSnapshot.exists) {
      var bookingData = bookingSnapshot.data();
      Get.snackbar("Booking Check", "Booking Exists");
      if (bookingData != null) {
        var sourceLocation = bookingData['pick_up_location'];
        var destination = bookingData['drop_off_location'];

        price = bookingData['price'];
        sourceText = bookingData['pick_up_text'];
        destinationText = bookingData['drop_off_text'];
        notesFromPassenger = bookingData['note_to_driver'] ?? "No notes";

        // sourceText = await authController.getAddressFromLatLng(
        //     sourceLocation.latitude, sourceLocation.longitude);
        // destinationText = await authController.getAddressFromLatLng(
        //     destination.latitude, destination.longitude);

        setState(() {
          markers.add(Marker(
            markerId: const MarkerId("source"),
            icon: sourceIcon,
            position: LatLng(sourceLocation.latitude, sourceLocation.longitude),
          ));

          markers.add(Marker(
            markerId: const MarkerId("destination"),
            icon: destinationIcon,
            position: LatLng(destination.latitude, destination.longitude),
          ));
          getPolyPoints(sourceLocation, destination);
        });
      }
    }
  }

  @override
  initState() {
    super.initState();
    userUid = authController.getCurrentUserUid();
    _getCurrentPosition();
    setCustomMarkerIcon();
    // getPaymentMethod();
    getBookingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      drawer: driverDrawer(),
      body: Column(
        children: [
          _currentLocation == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                )
              : SizedBox(
                  height: Get.height * .60,
                  child: googleMap(),
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
            child: interactionSection(),
          )
        ],
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
                text: sourceText == "" ? "Pick up at..." : sourceText,
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
                text:
                    destinationText == "" ? "Drop off at..." : destinationText,
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
            const SizedBox(width: 20),
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
                    height: Get.height * .1,
                    width: Get.width,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      notesFromPassenger,
                      style: GoogleFonts.varelaRound(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
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
            const SizedBox(width: 25),
            Image.asset(
              "assets/images/peso_icon.png",
              width: 20,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 5),
            Text(
              "$price",
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
            onPressed: () {
              driverController.sendDriverResponse(
                  userUid, bookingId, "accepted");
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
                  child: Text(
                    "60",
                    style: GoogleFonts.varelaRound(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
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
                  userUid, bookingId, "declined");
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              backgroundColor: Colors.white,
            ),
            child: Text("Decline",
                style: GoogleFonts.varelaRound(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                )),
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
            polylines: {
              Polyline(
                polylineId: const PolylineId("route"),
                points: polylineCoordinates,
                color: Colors.green,
                width: 6,
              ),
            },
            markers: markers,
          ),
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
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../chat_page.dart';
import '../driver_found_page.dart';
import 'booking_found_page.dart';
import 'driver_drawer.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  Position? _currentLocation;
  Set<Marker> markers = <Marker>{};

  Future<bool> _handleLocationPermission() async {
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

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
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

  @override
  void initState() {
    super.initState();
    _handleLocationPermission();
    _getCurrentPosition();
    // trackLoc();
    centerCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      drawer: driverDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            _currentLocation != null
                ? GoogleMap(
                    compassEnabled: false,
                    tiltGesturesEnabled: false,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: false,
                    myLocationEnabled: true,
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
                        color: Colors.green,
                        width: 6,
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
              bottom: 70,
              right: 20,
              child: CircleAvatar(
                radius: 30,
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
              bottom: 140,
              right: 20,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  onPressed: () {
                    centerCamera();
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 210,
              right: 20,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: IconButton(
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: () {
                    Get.to(() => const BookFoundPage());
                    // Get.bottomSheet(
                    //   isDismissible: false,
                    //   enableDrag: false,
                    //   Container(
                    //     height: Get.height * .40,
                    //     width: Get.width,
                    //     color: Colors.white,
                    //     child: Column(
                    //       children: [],
                    //     ),
                    //   ),
                    // );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: Get.width * .70,
                  child: openCollectCashDialog(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton openCollectCashDialog() {
    return ElevatedButton(
      onPressed: () {
        Get.defaultDialog(
            confirm: Container(
              width: Get.width * .75,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: openPaymentDialog(),
            ),
            title: "ALREADY ARRIVED AT DROP OFF POINT",
            titleStyle: GoogleFonts.varelaRound(
                fontWeight: FontWeight.bold, color: Colors.green),
            content: Column(
              children: [
                Image.asset(
                  "assets/images/sided_tricycle.png",
                  width: 100,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 3,
                  width: Get.width,
                  color: Colors.green.shade900,
                ),
                const SizedBox(height: 15),
                Text(
                  "COLLECT CASH",
                  style: GoogleFonts.varelaRound(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/peso_icon.png",
                      width: 16,
                      fit: BoxFit.cover,
                      color: Colors.green,
                    ),
                    Text(
                      "69.69",
                      style: GoogleFonts.varelaRound(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ));
      },
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(color: Colors.green.shade900, width: 2)),
      child: Text(
        "ARRIVE AT PICK UP POINT",
        style: GoogleFonts.varelaRound(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ElevatedButton openPaymentDialog() {
    return ElevatedButton(
      onPressed: () {
        Get.back();
        Get.defaultDialog(
          title: "",
          titlePadding: const EdgeInsets.all(0),
          contentPadding: const EdgeInsets.all(0),
          content: Column(
            children: [
              const Icon(
                Icons.payments_rounded,
                color: Colors.green,
                size: 100,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/peso_icon.png",
                    width: 16,
                    fit: BoxFit.cover,
                    color: Colors.green,
                  ),
                  Text(
                    "69.69",
                    style: GoogleFonts.varelaRound(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "PAYMENT SUCCESFUL",
                style: GoogleFonts.varelaRound(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          confirm: Container(
            width: Get.width * .75,
            padding: const EdgeInsets.only(bottom: 20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              child: Text(
                "CONFIRM",
                style: GoogleFonts.varelaRound(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: Text(
        "CONFIRM",
        style: GoogleFonts.varelaRound(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

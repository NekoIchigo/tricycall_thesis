import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../chat_page.dart';
import 'booking_found_page.dart';
import 'driver_drawer.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final googleApiKey = "AIzaSyBFPJ9b4hwLh_CwUAPEe8aMIGT4deavGCk";
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  Position? _currentLocation;
  Set<Marker> markers = <Marker>{};

  var userUid = "";
  var lat = "14.5547", lng = "121.0244";

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

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  BitmapDescriptor currentLocIcon = BitmapDescriptor.defaultMarker;

  void setCustomMarkerIcon() async {
    final Uint8List currentIcon =
        await getBytesFromAsset('assets/images/tricycle_icon.png', 50);
    currentLocIcon = BitmapDescriptor.fromBytes(currentIcon);
  }

  getCurrentUserUid() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    userUid = localStorage.getString("user_uid") ?? "";
  }

  trackLoc() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    var docId = getCurrentUserUid();
    debugPrint("curerntLoc = $_currentLocation");
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) async {
      _currentLocation = position;
      // update marker
      markers.add(Marker(
        markerId: const MarkerId("currentLoc"),
        icon: currentLocIcon,
        position:
            LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
      ));

      // update location in database
      await FirebaseFirestore.instance
          .collection('driver_status')
          .doc(docId)
          .set({
        'latitude': _currentLocation!.latitude,
        'longitude': _currentLocation!.longitude,
        'status': 'online' // offline, online, booked
      }, SetOptions(merge: true));
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _handleLocationPermission();
    _getCurrentPosition();
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
              bottom: 50,
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
              bottom: 100,
              right: 20,
              child: CircleAvatar(
                radius: 20,
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
              bottom: 150,
              right: 20,
              child: CircleAvatar(
                radius: 20,
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
            Positioned(
              bottom: 200,
              right: 20,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                child: IconButton(
                  icon:
                      const Icon(Icons.navigation_rounded, color: Colors.white),
                  onPressed: () async {
                    await launchUrl(Uri.parse(
                        'google.navigation:q=$lat,$lng&key=$googleApiKey'));
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

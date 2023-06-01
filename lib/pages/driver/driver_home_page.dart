import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricycall_thesis/controller/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/driver_controller.dart';
import '../../controller/notification_controller.dart';
import '../chat_page.dart';
import 'driver_drawer.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final googleApiKey = "AIzaSyBFPJ9b4hwLh_CwUAPEe8aMIGT4deavGCk";
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  DriverController driverController = Get.find<DriverController>();
  NotificationController notificationController =
      Get.find<NotificationController>();
  AuthController authController = Get.find<AuthController>();

  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  Position? _currentLocation;
  Set<Marker> markers = <Marker>{};

  var userUid = "";

  String status = "";
  bool isNear = false;

  Future<void> _getCurrentPosition() async {
    final hasPermission = await authController.handleLocationPermission();
    if (!hasPermission) {
      Get.snackbar("Location not permitted",
          "Please permit the use of location to use this app");
    }
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentLocation = position;
        initDriverStatus();
      });
    }).catchError((e) {
      debugPrint(e.toString());
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

  BitmapDescriptor currentLocIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor sourceLocIcon = BitmapDescriptor.defaultMarker;

  void setCustomMarkerIcon() async {
    final Uint8List currentIcon = await authController.getBytesFromAsset(
        'assets/images/tricycle_icon.png', 50);
    currentLocIcon = BitmapDescriptor.fromBytes(currentIcon);
    final Uint8List destination = await authController.getBytesFromAsset(
        'assets/images/destination_icon.png', 50);
    destinationIcon = BitmapDescriptor.fromBytes(destination);
    final Uint8List driverIcon = await authController.getBytesFromAsset(
        'assets/images/source_icon.png', 50);
    sourceLocIcon = BitmapDescriptor.fromBytes(driverIcon);
  }

  initDriverStatus() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    bool? isInit = localStorage.getBool("isDriverInit");
    if (isInit!) return; //if not firsttime opening the app

    Timestamp currentTimestamp = Timestamp.now();
    String? token = notificationController.fcmToken;
    await FirebaseFirestore.instance
        .collection('driver_status')
        .doc(userUid)
        .set({
      'latitude': _currentLocation!.latitude,
      'longitude': _currentLocation!.longitude,
      'token': token,
      'status': 'offline', // offline, online, booked
      'availability_timestamp': currentTimestamp,
    });
    Get.snackbar(
      "Welcome Driver!",
      "Go online to start getting bookings",
      backgroundColor: Colors.green.shade300,
    );
    localStorage.setBool("isDriverInit", true);
  }

  sendLiveLocation() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
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
          .doc(userUid)
          .update({
        'latitude': _currentLocation!.latitude,
        'longitude': _currentLocation!.longitude,
        // 'status': status // offline, online, booked
      });

      setState(() {
        if (driverController.isDriverBooked.value) {
          if (driverController.isPickUp.value) {
            navigateToDestination(
              80,
              driverController.bookingInfo.value.destinaiton!,
              LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
            );
          } else {
            navigateToDestination(
              80,
              driverController.bookingInfo.value.sourceLoc!,
              LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
            );
          }
        }
      });
    });
  }

  navigateToDestination(int range, LatLng destination, LatLng sourceLoc) {
    polylineCoordinates.clear();

    getPolyPoints(sourceLoc, destination);

    markers.add(
      Marker(
        markerId: const MarkerId("destination_marker"),
        icon: destinationIcon,
        position: LatLng(destination.latitude, destination.longitude),
      ),
    );

    if (sourceLoc != const LatLng(0.0, 0.0)) {
      var distance = Geolocator.distanceBetween(sourceLoc.latitude,
          sourceLoc.longitude, destination.latitude, destination.longitude);
      print(distance);
      if (distance < range) {
        isNear = true;
      } else {
        isNear = false;
      }
    }
  }

  updateStatus(String status) async {
    Timestamp currentTimestamp = Timestamp.now();
    await FirebaseFirestore.instance
        .collection('driver_status')
        .doc(userUid)
        .update({
      'status': status, // 'status': status // offline, online, booked
      'availability_timestamp': currentTimestamp,
    });
  }

  getUid() async {
    userUid = await authController.getCurrentUserUid();
  }

  void getPolyPoints(sourceLocation, destination) async {
    if (!driverController.isDriverBooked.value) return;

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

  @override
  void initState() {
    super.initState();
    getUid();
    setCustomMarkerIcon();
    _getCurrentPosition();
    centerCamera();
    sendLiveLocation();
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
                    polylines: Set<Polyline>.of(polylines.values),
                    markers: markers,
                  )
                : const Center(child: CircularProgressIndicator()),
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
              child: Visibility(
                visible: driverController.isDriverBooked.value,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.navigation_rounded,
                        color: Colors.white),
                    onPressed: () async {
                      // ignore: prefer_typing_uninitialized_variables
                      double lat = 0.0, lng = 0.0;
                      if (driverController.isPickUp.value) {
                        lat = driverController
                            .bookingInfo.value.destinaiton!.latitude;
                        lng = driverController
                            .bookingInfo.value.destinaiton!.longitude;
                      } else {
                        lat = driverController
                            .bookingInfo.value.sourceLoc!.latitude;
                        lng = driverController
                            .bookingInfo.value.sourceLoc!.longitude;
                      }
                      await launchUrl(Uri.parse(
                          'google.navigation:q=$lat,$lng&key=$googleApiKey'));
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 100.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible: !driverController.isDriverBooked.value,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: driverController.isDriverOnline.value
                        ? Colors.red
                        : Colors.green,
                    child: IconButton(
                      icon: const Icon(
                        Icons.power_settings_new_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () async {
                        driverController.isDriverOnline.value =
                            !driverController.isDriverOnline.value;
                        status = driverController.isDriverOnline.value
                            ? "online"
                            : "offline";
                        updateStatus(status);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible: isNear,
                  child: SizedBox(
                    width: Get.width * .70,
                    child: openCollectCashDialog(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isArrive = false;

  ElevatedButton openCollectCashDialog() {
    return ElevatedButton(
      onPressed: () {
        if (isArrive) {
          if (driverController.isPickUp.value) {
            polylineCoordinates.clear();
            notificationController.sendNotification(
              driverController.bookingInfo.value.driverId,
              driverController.bookingInfo.value.passengerToken,
              "Arrive at your destination!",
              "Please pay the driver to finish the transaction",
              "destination_arrive",
            );
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
          } else {
            driverController.isPickUp.value = true;
            isNear = false;
            notificationController.sendNotification(
              driverController.bookingInfo.value.driverId,
              driverController.bookingInfo.value.passengerToken,
              "Your trip starts",
              "Stay safe in your travel!",
              "trip_start",
            );
          }
        } else {
          isArrive = true;
          Get.snackbar("Pick up your passenger",
              "Please communicate with the passenger");
          notificationController.sendNotification(
            driverController.bookingInfo.value.driverId,
            driverController.bookingInfo.value.passengerToken,
            "Driver arrive at your Pick up location",
            "Please communicate with the driver to proceed",
            "driver_arrive",
          );
        }
        setState(() {});
      },
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(color: Colors.green.shade900, width: 2)),
      child: Text(
        isArrive
            ? driverController.isPickUp.value
                ? "ARRIVE AT LOCATION"
                : "PICK UP PASSENGER"
            : "ARRIVE AT PICK UP LOCATION",
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
                    "${driverController.bookingInfo.value.price}",
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
                notificationController.sendNotification(
                  driverController.bookingInfo.value.driverId,
                  driverController.bookingInfo.value.passengerToken,
                  "Transaction Complete!",
                  "Thank you for using our application",
                  "transaction_complete",
                );
                isArrive = false;
                driverController.isDriverBooked.value = false;
                driverController.isPickUp.value = false;
                isNear = false;
                updateStatus("online");
                markers.remove(const MarkerId(
                    "destination_marker")); // TODO check if marker is remove
                setState(() {});
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

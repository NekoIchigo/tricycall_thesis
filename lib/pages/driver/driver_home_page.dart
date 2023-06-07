import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final googleApiKey = "AIzaSyCbYWT5IPpryxcCqNmO_4EyFFCpIejPBf8";
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

  String userUid = "";

  String status = "";
  bool isNear = false;

  Future<void> _getCurrentPosition() async {
    final hasPermission = await authController.handleLocationPermission();
    if (!hasPermission) {
      Get.snackbar("Location not permitted",
          "Please permit the use of location to use this app",
          backgroundColor: Colors.green.shade300);
    }
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentLocation = position;
        driverController.initDriverStatus(
          notificationController.fcmToken!,
          _currentLocation!,
          userUid,
        );
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

  sendLiveLocation() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) async {
      if (mounted) {
        setState(() {
          _currentLocation = position;

          // update marker
          markers.add(Marker(
            markerId: const MarkerId("currentLoc"),
            icon: authController.driversIcon.value,
            position:
                LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
            infoWindow: const InfoWindow(title: "Your Location"),
          ));

          // update location in database
          FirebaseFirestore.instance
              .collection('driver_status')
              .doc(userUid)
              .update({
            'latitude': _currentLocation!.latitude,
            'longitude': _currentLocation!.longitude,
            // 'status': status // offline, online, booked
          });

          if (driverController.isDriverBooked.value) {
            if (driverController.isPickUp.value) {
              rangeChecker(
                80,
                driverController.bookingInfo.value.destinaiton!,
                LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
              );
            } else {
              rangeChecker(
                80,
                driverController.bookingInfo.value.sourceLoc!,
                LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
              );
            }
          }
        });
      }
    });
  }

  rangeChecker(int range, LatLng destination, LatLng sourceLoc) {
    if (sourceLoc != const LatLng(0.0, 0.0)) {
      var distance = Geolocator.distanceBetween(sourceLoc.latitude,
          sourceLoc.longitude, destination.latitude, destination.longitude);
      // print(distance);
      if (distance < range) {
        isNear = true;
      } else {
        isNear = false;
      }
    }
  }

  drawPolyLine() async {
    if (driverController.isDriverBooked.value) {
      LatLng destination = driverController.bookingInfo.value.destinaiton!;
      LatLng sourceLoc = driverController.bookingInfo.value.sourceLoc!;
      polylineCoordinates.clear();

      getPolyPoints(sourceLoc, destination);

      markers.add(
        Marker(
          markerId: const MarkerId("source_marker"),
          icon: authController.sourceIcon.value,
          position: LatLng(sourceLoc.latitude, sourceLoc.longitude),
          infoWindow: const InfoWindow(title: "Passenger pick up location"),
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId("destination_marker"),
          icon: authController.destinationIcon.value,
          position: LatLng(destination.latitude, destination.longitude),
          infoWindow: const InfoWindow(title: "Passenger drop off location"),
        ),
      );

      // if driver booked get passenger data
      driverController.passengerData.value = await authController
          .getUserData(driverController.bookingInfo.value.userId!);
    } else {
      return;
    }
  }

  getUid() async {
    userUid = await authController.getCurrentUserUid();
    driverController.driverData.value =
        await driverController.getDriverData(userUid);
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
    _getCurrentPosition();
    drawPolyLine();
    centerCamera();
    sendLiveLocation();
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
          child: Stack(
            children: [
              _currentLocation != null
                  ? GestureDetector(
                      behavior:
                          HitTestBehavior.opaque, // Absorb the scroll gestures
                      child: GoogleMap(
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
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
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
              Positioned(
                bottom: 100,
                right: 20,
                child: Visibility(
                  visible: driverController.isDriverBooked.value,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green,
                    child: IconButton(
                      icon: const Icon(Icons.chat, color: Colors.white),
                      onPressed: () {
                        Get.to(() => ChatPage(
                              bookingId: driverController.bookingId.value,
                              senderRole: "driver",
                            ));
                      },
                    ),
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
                    icon: const Icon(Icons.my_location, color: Colors.white),
                    onPressed: () {
                      // authController.sendEmailNotification(
                      //   "reydanjohnbelen@gmail.com",
                      //   "Madam/Sir",
                      //   "Reydan Pogi",
                      //   "Starmall Edsa",
                      //   14.582930626869585,
                      //   121.05352197211208,
                      //   "${driverController.driverData.value.firstName!} ${driverController.driverData.value.lastName!}",
                      //   driverController.pickUpTime.value,
                      //   driverController.dropOffTime.value,
                      // );

                      print(driverController.driverData.value.firstName);
                      print(driverController.pickUpTime.value);
                      print(driverController.dropOffTime.value);
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
              Positioned(
                bottom: 200,
                right: 20,
                child: Visibility(
                  visible: driverController.isDriverBooked.value,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green,
                    child: IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () {
                        bookingInfoDialog();
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
                          driverController.updateStatus(status, userUid);
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
            driverController.dropOffTime.value = Timestamp.now();
            // Get.snackbar("data",
            //     "${driverController.driverData.value.firstName!} ${driverController.driverData.value.lastName!}, ${driverController.pickUpTime.value}, ${driverController.dropOffTime.value}");
            authController.sendEmailNotification(
              driverController.passengerData.value.contactPerson!,
              "Madam/Si r",
              driverController.passengerData.value.firstName!,
              driverController.bookingInfo.value.destinationText!,
              driverController.bookingInfo.value.destinaiton!.latitude,
              driverController.bookingInfo.value.destinaiton!.longitude,
              "${driverController.driverData.value.firstName!} ${driverController.driverData.value.lastName!}",
              driverController.pickUpTime.value,
              driverController.dropOffTime.value,
            );
            var hint =
                driverController.bookingInfo.value.paymentMethod == "CASH"
                    ? "arrive_at_destination_cash"
                    : "arrive_at_destination_gcash";
            notificationController.sendNotification(
              driverController.bookingInfo.value.driverId,
              driverController.bookingInfo.value.passengerToken,
              "Arrive at your destination!",
              "Please pay the driver to finish the transaction",
              hint,
            );

            driverController.updateBookingStatus(
              driverController.bookingId.value,
              "payment",
            );
            collectPaymentDialog();
          } else {
            driverController.isPickUp.value = true;
            isNear = false;
            driverController.pickUpTime.value = Timestamp.now();
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
          Get.snackbar(
              "Pick up your passenger", "Please communicate with the passenger",
              backgroundColor: Colors.green.shade300);
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
                ? "ARRIVE AT DESTINATION"
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
                driverController.updateBookingStatus(
                  driverController.bookingId.value,
                  "finish",
                );
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
                driverController.updateStatus("online", userUid);
                markers.removeWhere(
                    (marker) => marker.markerId.value == 'destination_marker');
                markers.removeWhere(
                    (marker) => marker.markerId.value == 'source_marker');
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

  collectPaymentDialog() {
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
                "${driverController.bookingInfo.value.price}",
                style: GoogleFonts.varelaRound(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bookingInfoDialog() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(20),
      title: "Booking Information",
      titleStyle: GoogleFonts.varelaRound(
          fontWeight: FontWeight.bold, color: Colors.green),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "From: ",
            style: GoogleFonts.varelaRound(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20),
          Row(
            children: [
              Flexible(
                child: Text(
                  driverController.bookingInfo.value.sourceText ??
                      "Pick up location...",
                  style: GoogleFonts.varelaRound(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "To: ",
            style: GoogleFonts.varelaRound(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20),
          Row(
            children: [
              Flexible(
                child: Text(
                  driverController.bookingInfo.value.destinationText ??
                      "Drop off location...",
                  style: GoogleFonts.varelaRound(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Price: ",
                style: GoogleFonts.varelaRound(fontWeight: FontWeight.bold),
              ),
              Text(
                "${driverController.bookingInfo.value.price ?? "Drop off location..."}",
                style: GoogleFonts.varelaRound(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Payment Method: ",
                style: GoogleFonts.varelaRound(fontWeight: FontWeight.bold),
              ),
              Text(
                driverController.bookingInfo.value.paymentMethod ?? "CASH",
                style: GoogleFonts.varelaRound(),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Notes: ",
                style: GoogleFonts.varelaRound(fontWeight: FontWeight.bold),
              ),
              Text(
                driverController.bookingInfo.value.notes ?? "No Notes",
                style: GoogleFonts.varelaRound(),
              )
            ],
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        child: Text(
          "OKAY",
          style: GoogleFonts.varelaRound(),
        ),
      ),
    );
  }
}

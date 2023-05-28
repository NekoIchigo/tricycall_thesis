import 'dart:async';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricycall_thesis/pages/select_locations_page.dart';

import '../controller/auth_controller.dart';
import '../controller/notification_controller.dart';
import '../controller/passenger_controller.dart';
import '../models/tariff_calculator.dart';
import '../widgets/drawer.dart';
import 'package:group_radio_button/group_radio_button.dart';

import 'driver_found_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  then(void Function(dynamic value) param0) {}
}

class _HomePageState extends State<HomePage> {
  final googleApiKey = "AIzaSyBFPJ9b4hwLh_CwUAPEe8aMIGT4deavGCk";
  final Completer<GoogleMapController> _controller = Completer();
  AuthController authController = Get.find<AuthController>();
  PassengerController passengerController = Get.find<PassengerController>();
  NotificationController notificationController =
      Get.find<NotificationController>();

  String paymentMethod = "CASH";

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  String sourceText = "", destinationText = "";

// Polypoint variables
  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  double? travelPrice, minute, seconds;
  String? time;
  String _placeDistance = ""; // Stores total distance of polyline

  Position? _currentLocation;
  Set<Marker> markers = <Marker>{};

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker,
      destinationIcon = BitmapDescriptor.defaultMarker,
      currentLocIcon = BitmapDescriptor.defaultMarker;

  bool isBookClicked = false;

  var userUid = "";

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
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> trackLoc() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      _currentLocation = position;
      setState(() {});
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

  getPaymentMethod() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      paymentMethod = localStorage.getString("payment_method") ?? "CASH";
    });
  }

  TextEditingController noteToDriver = TextEditingController();
  setNoteToDriver() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setString("note_to_driver", noteToDriver.text);
  }

  // TODO : Assign an empty value to locastorage source and destination after transaction
  getSourceLatLong() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    late LatLng sourceLocation;

    var place = localStorage.getString("source") ?? "";
    sourceText = place;
    print("SourceText = $sourceText");

    sourceLocation = await authController.buildLatLngFromAddress(place);
    print("sourcelatlng =$sourceLocation");

    return sourceLocation;
  }

  getDestinationLatLong() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    late LatLng destination;

    var place = localStorage.getString("destination") ?? "";
    destinationText = place;
    print("DestinationText = $destinationText");

    destination = await authController.buildLatLngFromAddress(place);
    print("DesLatLng = $destination");
    return destination;
  }

  void getPolyPoints(sourceLocation, destination) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );
    // print("polylineres = $result");
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      // Defining an ID
      PolylineId id = PolylineId('poly');

      // Initializing Polyline
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 3,
      );

      // Adding the polyline to the map
      polylines[id] = polyline;
    }
    double totalDistance = 0.0;

    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += authController.coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }

// Storing the calculated total distance of the route
    setState(() {
      _placeDistance = totalDistance.toStringAsFixed(2);
      localStorage.setString("total_distance", _placeDistance);
      travelPrice = TariffCalculator.calculateTariff(
          totalDistance.toInt(), 3, true, true);
      debugPrint('DISTANCE: $_placeDistance km');
      minute = ((totalDistance / 20) * 60);
      seconds = minute! - minute!.toInt();
      seconds = seconds! * 60;
      time = "${minute!.toInt()}: ${seconds!.toInt()}";
    });
  }

  setPolyPoint() async {
    late LatLng sourceLocation;
    late LatLng destination;

    sourceLocation = await getSourceLatLong();
    markers.add(Marker(
      markerId: const MarkerId("source"),
      icon: sourceIcon,
      position: sourceLocation,
    ));

    destination = await getDestinationLatLong();
    markers.add(Marker(
      markerId: const MarkerId("destination"),
      icon: destinationIcon,
      position: destination,
    ));

    getPolyPoints(sourceLocation, destination);

    setState(() {});
  }

  getCurrentUserUid() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    userUid = localStorage.getString("user_uid") ?? "";
  }

  void displayOnlineDriversOnMap() {
    FirebaseFirestore.instance
        .collection('driver_status')
        .where('status', isEqualTo: 'online')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var documentSnapshot in querySnapshot.docs) {
        double latitude = documentSnapshot['latitude'];
        double longitude = documentSnapshot['longitude'];

        // Create a Marker for each online driver
        Marker marker = Marker(
          markerId: MarkerId(documentSnapshot.id),
          position: LatLng(latitude, longitude),
          // Add any other customization for the marker, e.g., icon, info window, etc.
        );

        markers.add(marker);
      }
    });
  }

  @override
  initState() {
    super.initState();
    _getCurrentPosition();
    trackLoc();
    setCustomMarkerIcon();
    getPaymentMethod();
    getCurrentUserUid();
    setPolyPoint();
    displayOnlineDriversOnMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      key: scaffoldState,
      body: Column(
        children: [
          _currentLocation == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                )
              : SizedBox(
                  height: Get.height * .55,
                  child: googleMap(),
                ),
          Container(
            height: Get.height * .25,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: interactionSection(),
          ),
          Container(
            height: Get.height * .20,
            decoration: const BoxDecoration(
              color: Color(0xFFE7FFF4),
            ),
            child: informationDetails(),
          )
        ],
      ),
    );
  }

  Column interactionSection() {
    return Column(
      children: [
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
              InkWell(
                onTap: () {
                  Get.to(() => const SelectLocations())!
                      .then((value) => setState(() {}));
                },
                child: fieldSourceDestination(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        isBookClicked
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Looking for Tricycle near you",
                    style: GoogleFonts.varelaRound(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  LoadingAnimationWidget.prograssiveDots(
                      color: Colors.green, size: 26)
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(child: SizedBox()),
                  paymentMethodButton(),
                  const SizedBox(width: 10),
                  noteDriverButton(),
                  const Expanded(child: SizedBox()),
                ],
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

  Widget paymentMethodButton() {
    return InkWell(
      onTap: () {
        Get.defaultDialog(
          title: "Payment Method:",
          titleStyle: GoogleFonts.varelaRound(
            fontSize: 14,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
          titlePadding: const EdgeInsets.symmetric(vertical: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          content: const RadioButtonSection(),
          cancel: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Get.back();
              },
              child: const Text("Cancel"),
            ),
          ),
          confirm: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("Confirm"),
            ),
          ),
        );
      },
      child: Container(
        height: 50,
        width: Get.width * .45,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.payments_rounded,
              color: Colors.green,
            ),
            const SizedBox(width: 10),
            Text(
              "Payment",
              style: GoogleFonts.varelaRound(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget noteDriverButton() {
    return InkWell(
      onTap: () {
        Get.defaultDialog(
          title: "Notes to driver:",
          titleStyle: GoogleFonts.varelaRound(
            fontSize: 14,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
          titlePadding: const EdgeInsets.symmetric(vertical: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          content: TextFormField(
            controller: noteToDriver,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),
          cancel: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Get.back();
              },
              child: const Text("Cancel"),
            ),
          ),
          confirm: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ElevatedButton(
              onPressed: () {
                setNoteToDriver();
                Get.back();
              },
              child: const Text("Confirm"),
            ),
          ),
        );
      },
      child: Container(
        height: 50,
        width: Get.width * .45,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.note_add_sharp,
              color: Colors.green,
            ),
            const SizedBox(width: 10),
            Text(
              "Notes to Driver",
              style: GoogleFonts.varelaRound(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget informationDetails() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: Get.width * .35,
                child: Center(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.green,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        time ?? "Time",
                        style: GoogleFonts.varelaRound(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 75),
              SizedBox(
                width: Get.width * .35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      "assets/images/peso_icon.png",
                      color: Colors.green,
                      width: 25,
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Get.to(() => const DriverFoundPage());
                      },
                      child: Text(
                        "${travelPrice?.toStringAsFixed(2) ?? "Price"} ",
                        style: GoogleFonts.varelaRound(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(width: Get.width * .05),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  String? token = notificationController.fcmToken;
                  isBookClicked
                      ? null
                      : passengerController.storeBookingInfo(token);
                  setState(() {
                    isBookClicked = !isBookClicked;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBookClicked ? Colors.white : Colors.green,
                  side: BorderSide(color: Colors.green.shade900),
                  padding:
                      EdgeInsets.symmetric(vertical: isBookClicked ? 7 : 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isBookClicked
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(child: SizedBox()),
                          Text(
                            "Cancel",
                            style: GoogleFonts.varelaRound(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          SizedBox(width: Get.width * .22),
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              "60",
                              style: GoogleFonts.varelaRound(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      )
                    : Text(
                        "Book a ride",
                        style: GoogleFonts.varelaRound(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(width: Get.width * .05),
          ],
        )
      ],
    );
  }

  Widget googleMap() {
    return SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            compassEnabled: false,
            tiltGesturesEnabled: false,
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

class RadioButtonSection extends StatefulWidget {
  const RadioButtonSection({
    Key? key,
  }) : super(key: key);

  @override
  State<RadioButtonSection> createState() => _RadioButtonSectionState();
}

class _RadioButtonSectionState extends State<RadioButtonSection> {
  late SharedPreferences localStorage;
  String? singleValue = "CASH";

  getPayment() async {
    localStorage = await SharedPreferences.getInstance();

    singleValue = localStorage.getString("payment_method");
  }

  setPayment() async {
    localStorage = await SharedPreferences.getInstance();
    localStorage.setString("payment_method", singleValue!);
    // print("Store $singleValue");
  }

  @override
  void initState() {
    super.initState();
    getPayment();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioButton(
          description: "CASH",
          value: "CASH",
          groupValue: singleValue,
          onChanged: (value) => setState(
            () {
              singleValue = value;
              // print(singleValue);
              setPayment();
            },
          ),
        ),
        RadioButton(
          description: "GCASH",
          value: "GCASH",
          groupValue: singleValue,
          onChanged: (value) => setState(
            () {
              singleValue = value;
              // print(singleValue);
              setPayment();
            },
          ),
        ),
      ],
    );
  }
}

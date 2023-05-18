import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricycall_thesis/pages/driver_found_page.dart';
import 'package:tricycall_thesis/pages/select_locations_page.dart';

import 'package:group_radio_button/group_radio_button.dart';

import '../../controller/auth_controller.dart';
import 'driver_drawer.dart';

class BookFoundPage extends StatefulWidget {
  const BookFoundPage({super.key});

  @override
  State<BookFoundPage> createState() => _BookFoundPageState();
}

class _BookFoundPageState extends State<BookFoundPage> {
  final googleApiKey = "AIzaSyBFPJ9b4hwLh_CwUAPEe8aMIGT4deavGCk";
  AuthController authController = Get.find<AuthController>();
  final Completer<GoogleMapController> _controller = Completer();

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  Position? _currentLocation;
  String sourceText = "", destinationText = "";

  List<LatLng> polylineCoordinates = [];
  Set<Marker> markers = <Marker>{};

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker,
      destinationIcon = BitmapDescriptor.defaultMarker,
      currentLocIcon = BitmapDescriptor.defaultMarker;

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

  void setCustomMarkerIcon() async {
    final Uint8List source =
        await getBytesFromAsset('assets/images/source_icon.png', 50);
    sourceIcon = BitmapDescriptor.fromBytes(source);
    final Uint8List destination =
        await getBytesFromAsset('assets/images/destination_icon.png', 50);
    destinationIcon = BitmapDescriptor.fromBytes(destination);
    final Uint8List currentIcon =
        await getBytesFromAsset('assets/images/tricycle_icon.png', 80);
    currentLocIcon = BitmapDescriptor.fromBytes(currentIcon);
  }

  getSourceLatLong() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    late LatLng sourceLocation;

    var place = localStorage.getString("source") ?? "";
    sourceText = place;
    // print("SourceText = $sourceText");

    sourceLocation = await authController.buildLatLngFromAddress(place);
    // print("sourcelatlng =$sourceLocation");
    markers.add(Marker(
      markerId: const MarkerId("source"),
      icon: sourceIcon,
      position: sourceLocation,
    ));

    return sourceLocation;
  }

  getDestinationLatLong() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    late LatLng destination;

    var place = localStorage.getString("destination") ?? "";
    destinationText = place;
    // print("DestinationText = $destinationText");

    destination = await authController.buildLatLngFromAddress(place);
    // print("DesLatLng = $destination");
    markers.add(Marker(
      markerId: const MarkerId("destination"),
      icon: destinationIcon,
      position: destination,
    ));

    return destination;
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

  setPolyPoint() async {
    late LatLng sourceLocation;
    late LatLng destination;

    sourceLocation = await getSourceLatLong();
    destination = await getDestinationLatLong();

    setState(() {
      getPolyPoints(sourceLocation, destination);
    });
  }

  @override
  initState() {
    super.initState();
    _handleLocationPermission();
    _getCurrentPosition();
    // trackLoc();
    setCustomMarkerIcon();
    // getPaymentMethod();
    setPolyPoint();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      drawer: driverDrawer(),
      body: SingleChildScrollView(
        child: Column(
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
              height: Get.height * .23,
              width: Get.width,
              decoration: const BoxDecoration(
                color: Color(0xFFE7FFF4),
              ),
              child: interactionSection(),
            )
          ],
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
              onPressed: () {},
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
              "50.00",
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
            onPressed: () {},
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
            onPressed: () {},
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

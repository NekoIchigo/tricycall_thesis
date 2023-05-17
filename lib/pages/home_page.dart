import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final googleApiKey = "AIzaSyBFPJ9b4hwLh_CwUAPEe8aMIGT4deavGCk  ";
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation =
      LatLng(14.572926943121129, 121.02870852887001);
  static const LatLng destination = LatLng(14.5871, 120.9845);

  List<LatLng> polylineCoordinates = [];
  Position? _currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocIcon = BitmapDescriptor.defaultMarker;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() => _currentLocation = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  trackLoc() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    GoogleMapController googleMapController = await _controller.future;

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      _currentLocation = position;
      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
      setState(() {});
    }
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
    final Uint8List destination =
        await getBytesFromAsset('assets/images/destination_icon.png', 80);
    destinationIcon = BitmapDescriptor.fromBytes(destination);
    final Uint8List currentIcon =
        await getBytesFromAsset('assets/images/tricycle_icon.png', 80);
    currentLocIcon = BitmapDescriptor.fromBytes(currentIcon);
  }

  @override
  initState() {
    _handleLocationPermission();
    _getCurrentPosition();
    trackLoc();
    setCustomMarkerIcon();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              height: Get.height * .23,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: interactionSection(),
            ),
            Container(
              height: Get.height * .17,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: informationDetails(),
            )
          ],
        ),
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
                child: Stack(
                  children: [
                    Positioned(
                      top: 5,
                      left: 20,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
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
                        decoration: BoxDecoration(
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
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 13,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Pick up at...",
                      style: GoogleFonts.varelaRound(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      " Drop off at...",
                      style: GoogleFonts.varelaRound(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: SizedBox()),
            InkWell(
              onTap: () {},
              child: Container(
                width: Get.width * .35,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_rounded,
                      color: Colors.green,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Payment",
                      style: GoogleFonts.varelaRound(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 20),
            InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_add_sharp,
                      color: Colors.green,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Notes to Driver",
                      style: GoogleFonts.varelaRound(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: SizedBox()),
          ],
        )
      ],
    );
  }

  Column informationDetails() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: SizedBox()),
              Container(
                width: Get.width * .35,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                ),
                child: Center(
                  child: Row(
                    children: [
                      Container(
                        child: Icon(
                          Icons.access_time,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "10 min",
                        style: GoogleFonts.varelaRound(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 20),
              Container(
                width: Get.width * .35,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Container(
                      child: Image.asset(
                        "assets/images/peso_icon.png",
                        color: Colors.green,
                        width: 25,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "150.00",
                      style: GoogleFonts.varelaRound(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
        Row(
          children: [
            SizedBox(width: Get.width * .05),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  "Book",
                  style: GoogleFonts.varelaRound(
                    fontSize: 12,
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
    return Stack(children: [
      GoogleMap(
        onMapCreated: (mapContorller) {
          _controller.complete(mapContorller);
        },
        initialCameraPosition: CameraPosition(
          target:
              LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
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
        markers: {
          Marker(
            markerId: const MarkerId("source"),
            // icon: sourceIcon,
            position: sourceLocation,
          ),
          Marker(
            markerId: const MarkerId("destination"),
            icon: destinationIcon,
            position: destination,
          ),
          Marker(
            markerId: const MarkerId("currentLocation"),
            icon: currentLocIcon,
            position:
                LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          ),
        },
      ),
    ]);
  }
}
// drawer: buildDrawer(),
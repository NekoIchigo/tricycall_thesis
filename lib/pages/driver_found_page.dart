import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../widgets/drawer.dart';
import 'chat_page.dart';

class DriverFoundPage extends StatefulWidget {
  const DriverFoundPage({super.key});

  @override
  State<DriverFoundPage> createState() => _DriverFoundPageState();
}

class _DriverFoundPageState extends State<DriverFoundPage> {
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

  // trackLoc() async {
  //   const LocationSettings locationSettings = LocationSettings(
  //     accuracy: LocationAccuracy.high,
  //     distanceFilter: 10,
  //   );

  //   Geolocator.getPositionStream(locationSettings: locationSettings)
  //       .listen((Position? position) {
  //     _currentLocation = position;
  //     setState(() {});
  //   });
  // }

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
      drawer: buildDrawer(),
      key: scaffoldState,
      body: SizedBox(
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
                bottom: 10,
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
                bottom: 80,
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
                bottom: 150,
                right: 20,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.check, color: Colors.white),
                    onPressed: () {
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
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
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
                    },
                  ),
                ),
              ),
            ],
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
      initialRating: 3,
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

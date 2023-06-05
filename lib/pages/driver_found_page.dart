import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/notification_controller.dart';
import '../controller/passenger_controller.dart';
import '../models/booking_model.dart';
import '../widgets/drawer.dart';
import 'chat_page.dart';

class DriverFoundPage extends StatefulWidget {
  const DriverFoundPage({super.key});

  @override
  State<DriverFoundPage> createState() => _DriverFoundPageState();
}

class _DriverFoundPageState extends State<DriverFoundPage> {
  final googleApiKey = "AIzaSyCbYWT5IPpryxcCqNmO_4EyFFCpIejPBf8";

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  PassengerController passengerController = Get.find<PassengerController>();
  NotificationController notificationController =
      Get.find<NotificationController>();

  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  Position? _currentLocation;
  Set<Marker> markers = <Marker>{};
  String driverIdFromBooking = "";

  late BookingModel bookingInfo;

  Future<void> _getCurrentPosition() async {
    final hasPermission = await authController.handleLocationPermission();
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

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    GoogleMapController googleMapController = await _controller.future;

    await googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              snapshot.data!.docs
                  .singleWhere((element) => element.id == "user1")['latitude'],
              snapshot.data!.docs
                  .singleWhere((element) => element.id == "user1")['longitude'],
            ),
            zoom: 14.47)));
  }

  getDriverIdFromBooking() async {
    var id = passengerController.bookingId.value;
    var bookingData =
        await FirebaseFirestore.instance.collection('bookings').doc(id).get();

    if (bookingData.exists) {
      driverIdFromBooking = bookingData.data()!['driver_id'];
      bookingInfo = BookingModel.fromJson(bookingData.data()!);
    }
  }

  PolylinePoints polylinePoints = PolylinePoints();

  Future<List<LatLng>> getPolylinePoints(
      LatLng sourceLocation, LatLng destination) async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    return polylineCoordinates;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    centerCamera();
    getDriverIdFromBooking();
  }

  bool isPolyLineDrawned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      key: scaffoldState,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('driver_status')
            .doc(notificationController.driverId.value
                .toString()) // Replace 'driverIdFromBooking' with the actual driver ID
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final driverStatus = snapshot.data;

          if (driverStatus == null || !driverStatus.exists) {
            return const Text('Driver not found');
          }

          final driverData = driverStatus.data() as Map<String, dynamic>;
          final driverLocation = LatLng(
            driverData['latitude'] as double? ?? 0.0,
            driverData['longitude'] as double? ?? 0.0,
          );

          final destination = bookingInfo.destinaiton;
          final sourceLoc = bookingInfo.sourceLoc;

          if (!isPolyLineDrawned) {
            isPolyLineDrawned = true;
            getPolylinePoints(sourceLoc!, destination!)
                .then((List<LatLng> points) {
              markers.add(
                Marker(
                  markerId: const MarkerId('source'),
                  position: sourceLoc,
                  icon: authController.sourceIcon.value,
                  infoWindow: const InfoWindow(title: "Your pick up location"),
                ),
              );
              markers.add(
                Marker(
                  markerId: const MarkerId('destination'),
                  position: destination,
                  icon: authController.destinationIcon.value,
                  infoWindow: const InfoWindow(title: "Your drop off location"),
                ),
              );
              setState(() {
                polylineCoordinates = points;
              });
            });
          }

          markers.add(
            Marker(
              markerId: const MarkerId('driver'),
              position: driverLocation,
              icon: authController.driversIcon.value,
              infoWindow: const InfoWindow(title: "Your driver location"),
            ),
          );

          return SizedBox(
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
                              color: Colors.red,
                              width: 3,
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
                    bottom: 80,
                    right: 20,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon: const Icon(Icons.chat, color: Colors.white),
                        onPressed: () {
                          Get.to(() => ChatPage(
                                bookingId: passengerController.bookingId.value,
                                senderRole: "passenger",
                              ));
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 20,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon:
                            const Icon(Icons.my_location, color: Colors.white),
                        onPressed: () {
                          centerCamera();
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 130,
                    right: 20,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon:
                            const Icon(Icons.info_outline, color: Colors.white),
                        onPressed: () {
                          bookingInfoDialog();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  paymentDialog() {
    Get.defaultDialog(
        title: "Gcash Payment",
        content: Column(
          // TODO: implement gcash payment
          children: const [],
        ));
  }

  bookingInfoDialog() {
    Get.defaultDialog(
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
          Row(
            children: [
              Flexible(
                child: Text(
                  bookingInfo.sourceText ?? "Pick up location...",
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
          Row(
            children: [
              Flexible(
                child: Text(
                  bookingInfo.destinationText ?? "Drop off location...",
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
              const SizedBox(width: 20),
              Text(
                "${bookingInfo.price ?? "Drop off location..."}",
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
                bookingInfo.paymentMethod ?? "CASH",
                style: GoogleFonts.varelaRound(),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Notes: ",
            style: GoogleFonts.varelaRound(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Flexible(
                child: Text(
                  bookingInfo.notes ?? "No Notes",
                  style: GoogleFonts.varelaRound(),
                ),
              ),
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

class RatingSection extends StatefulWidget {
  const RatingSection({super.key});

  @override
  State<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<RatingSection> {
  PassengerController passengerController = Get.find<PassengerController>();

  storeRatingInformation(rating) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setInt("rating_value", rating);
  }

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: 5.0,
      minRating: 1,
      direction: Axis.horizontal,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        storeRatingInformation(rating.toInt());
      },
    );
  }
}

class RatingContent extends StatefulWidget {
  final String bookindId;
  final String driverId;
  const RatingContent({
    Key? key,
    required this.bookindId,
    required this.driverId,
  }) : super(key: key);

  @override
  State<RatingContent> createState() => _RatingContentState();
}

class _RatingContentState extends State<RatingContent> {
  PassengerController passengerController = Get.find<PassengerController>();

  TextEditingController commentController = TextEditingController();
  bool addComment = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "RATE YOUR DRIVER",
              style: GoogleFonts.varelaRound(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: Colors.green,
              radius: 15,
              child: IconButton(
                onPressed: () {
                  addComment = !addComment;
                  setState(() {});
                },
                icon: const Icon(
                  Icons.add_comment_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const RatingSection(),
        const SizedBox(height: 20),
        addComment
            ? SizedBox(
                width: Get.width * .8,
                child: TextFormField(
                  controller: commentController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Input your comment here...",
                    hintStyle: GoogleFonts.varelaRound(),
                  ),
                ),
              )
            : Image.asset("assets/images/sided_tricycle.png",
                width: 100, fit: BoxFit.cover),
        Container(
          height: 3,
          width: Get.width,
          color: Colors.green.shade900,
        ),
        ElevatedButton(
          onPressed: () async {
            SharedPreferences localStorage =
                await SharedPreferences.getInstance();
            localStorage.setString("payment_method", "CASH");
            localStorage.setString("note_to_driver", "");
            localStorage.setString("source", "");
            localStorage.setString("destination", "");
            localStorage.setString("total_distance", "");
            localStorage.setDouble("travel_price", 0.0);
            localStorage.setString("comment_value", commentController.text);

            passengerController.storeRatings(widget.bookindId, widget.driverId);
          },
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
      ],
    );
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paymongo_sdk/paymongo_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:tricycall_thesis/pages/select_locations_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/auth_controller.dart';
import '../controller/notification_controller.dart';
import '../controller/passenger_controller.dart';
import '../models/tariff_calculator.dart';
import '../widgets/drawer.dart';
import 'package:group_radio_button/group_radio_button.dart';

import '../widgets/webview.dart';
import 'driver_found_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  then(void Function(dynamic value) param0) {}
}

class _HomePageState extends State<HomePage> {
  final googleApiKey = "AIzaSyCbYWT5IPpryxcCqNmO_4EyFFCpIejPBf8";
  final Completer<GoogleMapController> _controller = Completer();
  AuthController authController = Get.find<AuthController>();
  PassengerController passengerController = Get.find<PassengerController>();
  NotificationController notificationController =
      Get.find<NotificationController>();

  String paymentMethod = "CASH";

  bool canCancel = true;
  final CountdownController _controllerTimer =
      CountdownController(autoStart: true);

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  String sourceText = "", destinationText = "";

// Polypoint variables
  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  double? travelPrice, minute, seconds;
  String? time;
  double totalDistance = 0.0;
  String _placeDistance = ""; // Stores total distance of polyline

  Position? _currentLocation;
  Set<Marker> markers = <Marker>{};

  bool isBookClicked = false;
  TextEditingController noteToDriver = TextEditingController();
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

  getPaymentMethod() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      paymentMethod = localStorage.getString("payment_method") ?? "CASH";
    });
  }

  setNoteToDriver() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setString("note_to_driver", noteToDriver.text);
  }

  getSourceLatLong() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    late LatLng sourceLocation;

    var place = localStorage.getString("source") ?? "";
    sourceText = place;
    // print("SourceText = $sourceText");

    sourceLocation = await authController.buildLatLngFromAddress(place);
    // print("sourcelatlng =$sourceLocation");

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
    }

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
      setPrice();
      setTime();
    });
  }

  setPrice() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    int totalPassenger = localStorage.getInt("total_passengers") ?? 1;
    travelPrice = // TODO : fix computation
        TariffCalculator.calculateTariff(
            totalDistance.toInt(), totalPassenger, true, true);
    localStorage.setInt("travel_price", travelPrice!.toInt());
  }

  setTime() {
    minute = ((totalDistance / 20) * 60);
    seconds = minute! - minute!.toInt();
    seconds = seconds! * 60;
    time = "${minute!.toInt()}: ${seconds!.toInt()}";
  }

  setPolyPoint() async {
    if (passengerController.isAssignedRoute.value) {
      late LatLng sourceLocation;
      late LatLng destination;

      sourceLocation = await getSourceLatLong();
      markers.add(Marker(
        markerId: const MarkerId("source"),
        icon: authController.sourceIcon.value,
        position: sourceLocation,
        infoWindow: const InfoWindow(title: "Your pick up location"),
      ));

      destination = await getDestinationLatLong();
      markers.add(Marker(
        markerId: const MarkerId("destination"),
        icon: authController.destinationIcon.value,
        position: destination,
        infoWindow: const InfoWindow(title: "Your drop off location"),
      ));

      getPolyPoints(sourceLocation, destination);

      setState(() {});
    } else {
      return;
    }
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
          icon: authController.driversIcon.value,
        );

        markers.add(marker);
      }
    });
  }

  // final Uri _url =
  //     Uri.parse('https://pm.link/org-FSjssrznvGpyUWue7JPNkB1g/test/EqQ3Wh4');

  // Future<void> _launchUrl() async {
  //   if (!await launchUrl(_url)) {
  //     throw Exception('Could not launch $_url');
  //   }
  // }

  @override
  initState() {
    super.initState();
    _getCurrentPosition();
    getPaymentMethod();
    getCurrentUserUid();
    setPolyPoint();
    displayOnlineDriversOnMap();
    passengerController.getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      key: scaffoldState,
      body: SingleChildScrollView(
        child: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Column(
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
              Column(
                children: [
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
                  ),
                ],
              )
            ],
          ),
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
                child: leftLocationIcons(),
              ),
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  Get.to(() => SelectLocations(
                            currentLocation: _currentLocation,
                          ))!
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
          barrierDismissible: false,
          titlePadding: const EdgeInsets.symmetric(vertical: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          content: const PaymentMethod(),
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
        height: Get.height * 0.06,
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
          barrierDismissible: false,
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
        height: Get.height * 0.06,
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
                        log("Paymongo Called");
                        // _launchUrl();
                        Get.to(() => const WebViewScreen(
                              url:
                                  'https://pm.link/org-FSjssrznvGpyUWue7JPNkB1g/test/EqQ3Wh4',
                            ));
                      },
                      child: Text(
                        "${travelPrice?.toStringAsFixed(2) ?? "Price"} ",
                        style: GoogleFonts.varelaRound(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // TextButton(  // * Important this code close the app
                    //   onPressed: () {
                    //     SystemChannels.platform
                    //         .invokeMethod('SystemNavigator.pop');
                    //   },
                    //   child: Text('Back'),
                    // ),
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
                  if (sourceText == "" || destinationText == "") {
                    Get.snackbar("Missing Input",
                        "Please input the necessary informations",
                        backgroundColor: Colors.red.shade200);
                  } else {
                    if (canCancel) {
                      if (isBookClicked) {
                        _controllerTimer.onRestart;
                        _controllerTimer.onPause;
                        log("timer restrat stop");
                      } else {
                        _controllerTimer.onStart;
                        log("timer start");
                      }
                      setState(() {
                        isBookClicked = !isBookClicked;
                      });
                    }
                  }
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
                            canCancel ? "Cancel" : "Waiting",
                            style: GoogleFonts.varelaRound(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          SizedBox(width: Get.width * .22),
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Countdown(
                              controller: _controllerTimer,
                              seconds: 15,
                              build: (BuildContext context, double time) {
                                return Text(time.toStringAsFixed(0),
                                    style: GoogleFonts.varelaRound(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ));
                              },
                              interval: const Duration(seconds: 1),
                              onFinished: () {
                                log("timer done");
                                String? token = notificationController.fcmToken;
                                passengerController.storeBookingInfo(token);
                                setState(() {
                                  canCancel = false; //TODO add function here
                                });
                              },
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Get.defaultDialog(
                    title: "Number of Passengers:",
                    titleStyle: GoogleFonts.varelaRound(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    barrierDismissible: false,
                    titlePadding: const EdgeInsets.symmetric(vertical: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    content: const TotalPassengers(),
                    cancel: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
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
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: Get.width * .13,
                      color: Colors.green,
                    ),
                    Text(
                      "# Passengers",
                      style: GoogleFonts.varelaRound(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
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

class TotalPassengers extends StatefulWidget {
  const TotalPassengers({super.key});

  @override
  State<TotalPassengers> createState() => _TotalPassengersState();
}

class _TotalPassengersState extends State<TotalPassengers> {
  late SharedPreferences localStorage;
  int? singleValue = 1;

  getTotalPassenger() async {
    localStorage = await SharedPreferences.getInstance();

    singleValue = localStorage.getInt("total_passengers") ?? 1;
  }

  setTotalPassenger() async {
    localStorage = await SharedPreferences.getInstance();
    localStorage.setInt("total_passengers", singleValue!);
    // print("Store $singleValue");
  }

  @override
  void initState() {
    super.initState();
    getTotalPassenger();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioButton(
          description: "1 Passenger",
          value: 1,
          groupValue: singleValue,
          onChanged: (value) => setState(
            () {
              singleValue = value;
              // print(singleValue);
              setTotalPassenger();
            },
          ),
        ),
        RadioButton(
          description: "2 Passengers",
          value: 2,
          groupValue: singleValue,
          onChanged: (value) => setState(
            () {
              singleValue = value;
              // print(singleValue);
              setTotalPassenger();
            },
          ),
        ),
        RadioButton(
          description: "3 Passengers",
          value: 3,
          groupValue: singleValue,
          onChanged: (value) => setState(
            () {
              singleValue = value;
              // print(singleValue);
              setTotalPassenger();
            },
          ),
        ),
        RadioButton(
          description: "4 Passengers",
          value: 4,
          groupValue: singleValue,
          onChanged: (value) => setState(
            () {
              singleValue = value;
              // print(singleValue);
              setTotalPassenger();
            },
          ),
        ),
      ],
    );
  }
}

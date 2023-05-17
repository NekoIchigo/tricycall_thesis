import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/auth_controller.dart';
import 'account_setting_page.dart';
import 'package:group_radio_button/group_radio_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthController authController = Get.find<AuthController>();
  final googleApiKey = "AIzaSyBFPJ9b4hwLh_CwUAPEe8aMIGT4deavGCk  ";
  final Completer<GoogleMapController> _controller = Completer();

  String paymentMethod = "CASH";

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
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

  late SharedPreferences localStorage;
  getPaymentMethod() async {
    localStorage = await SharedPreferences.getInstance();
    setState(() {
      paymentMethod = localStorage.getString("payment_method") ?? "CASH";
    });
  }

  TextEditingController noteToDriver = TextEditingController();
  setNoteToDriver() async {
    localStorage.setString("noteToDriver", noteToDriver.text);
  }

  @override
  initState() {
    _handleLocationPermission();
    _getCurrentPosition();
    trackLoc();
    setCustomMarkerIcon();
    getPolyPoints();
    getPaymentMethod();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      key: scaffoldState,
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
              height: Get.height * .22,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: interactionSection(),
            ),
            Container(
              height: Get.height * .18,
              decoration: BoxDecoration(
                color: Color(0xFFE7FFF4),
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
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      " Drop off at...",
                      style: GoogleFonts.varelaRound(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: SizedBox()),
            paymentMethodButton(),
            SizedBox(width: 10),
            noteDriverButton(),
            Expanded(child: SizedBox()),
          ],
        )
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
          titlePadding: EdgeInsets.symmetric(vertical: 20),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          content: RadioButtonSection(),
          cancel: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Get.back();
              },
              child: Text("Cancel"),
            ),
          ),
          confirm: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: Text("Confirm"),
            ),
          ),
        );
      },
      child: Container(
        height: 50,
        width: Get.width * .45,
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
          titlePadding: EdgeInsets.symmetric(vertical: 20),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          content: TextFormField(
            controller: noteToDriver,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
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
              child: Text("Cancel"),
            ),
          ),
          confirm: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ElevatedButton(
              onPressed: () {
                setNoteToDriver();
                Get.back();
              },
              child: Text("Confirm"),
            ),
          ),
        );
      },
      child: Container(
        height: 50,
        width: Get.width * .45,
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
              Container(
                width: Get.width * .35,
                child: Center(
                  child: Row(
                    children: [
                      Container(
                        child: Icon(
                          Icons.access_time,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "10 min",
                        style: GoogleFonts.varelaRound(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 75),
              Container(
                width: Get.width * .35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            SizedBox(width: Get.width * .05),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
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
                position: LatLng(
                    _currentLocation!.latitude, _currentLocation!.longitude),
              ),
            },
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

  Widget buildDrawer() {
    final List<String> items = [
      "Ride History",
      "Settings",
      "Support",
      "Log out"
    ];
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          drawerHeader(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: SizedBox(
                height: Get.height * 0.60,
                child: ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      dense: true,
                      onTap: () {
                        // authController.signOut();
                      },
                      title: Text(
                        items[index],
                        style: GoogleFonts.varelaRound(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Footer Here",
                  style: GoogleFonts.varelaRound(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "Copy Right \u00a9 TricyCall Team",
                  style: GoogleFonts.varelaRound(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget drawerHeader() {
    return SizedBox(
      height: 150,
      child: DrawerHeader(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                Get.to(() => const AccountSettingPage());
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: authController.myUser.value.image == null
                      ? const DecorationImage(
                          image: AssetImage(
                            "assets/images/profile-placeholder.png",
                          ),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image:
                              NetworkImage(authController.myUser.value.image!),
                          fit: BoxFit.cover),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Good Morning",
                  style: GoogleFonts.varelaRound(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  authController.myUser.value.firstName ?? "User",
                  style: GoogleFonts.varelaRound(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
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
    print("Store $singleValue");
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
              print(singleValue);
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
              print(singleValue);
              setPayment();
            },
          ),
        ),
      ],
    );
  }
}

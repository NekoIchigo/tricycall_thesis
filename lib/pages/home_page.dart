import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tricycall_thesis/controller/auth_controller.dart';

import '../widgets/build_drawer.dart';
import '../widgets/build_profile_tile.dart';
import '../widgets/build_text_field.dart';
import '../widgets/build_text_field_source.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(14.5871, 120.9845),
    zoom: 14.4746,
  );

  GoogleMapController? myMapController;
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  AuthController authController = Get.find<AuthController>();

  Set<Marker> markers = <Marker>{};

  @override
  void initState() {
    super.initState();

    authController.getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      drawer: const BuildDrawer(),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            markers: markers,
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              myMapController = controller;
            },
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 15),
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
          ),
          Positioned(
            top: Get.height * .10,
            child: buildProfileTile(),
          ),
          Positioned(
            top: Get.height * .30,
            child: BuildTextFieldForSource(
              showGoogleAutoComplete: showGoogleAutoComplete,
              marker: markers,
              mapController: myMapController,
            ),
          ),
          Positioned(
            top: Get.height * .41,
            child: BuildTextField(
              showGoogleAutoComplete: showGoogleAutoComplete,
              marker: markers,
              mapController: myMapController,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 30.0,
                horizontal: 10,
              ),
              child: buildCurrentLocationIcon(),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 30.0,
                horizontal: 10,
              ),
              child: buildCurrentNotificationIcon(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: buildBottomSheet(),
          ),
        ],
      ),
    );
  }

  Future<String> showGoogleAutoComplete() async {
    const kGoogleApiKey = "AIzaSyBFPJ9b4hwLh_CwUAPEe8aMIGT4deavGCk";

    Prediction? p = await PlacesAutocomplete.show(
        offset: 0,
        types: [],
        radius: 1000,
        strictbounds: false,
        region: 'ph',
        context: context,
        apiKey: kGoogleApiKey,
        mode: Mode.overlay, // Mode.fullscreen
        language: "en",
        components: [Component(Component.country, "ph")]);

    return p!.description!;
  }

  Widget buildCurrentLocationIcon() {
    return const CircleAvatar(
      radius: 20,
      backgroundColor: Colors.green,
      child: Icon(
        Icons.my_location,
        color: Colors.white,
      ),
    );
  }

  Widget buildCurrentNotificationIcon() {
    return const CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.notifications_none_rounded,
      ),
    );
  }

  Widget buildBottomSheet() {
    return Container(
      width: Get.width * 0.80,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 5,
            blurRadius: 1,
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Container(
          width: Get.width * 0.45,
          height: 5,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

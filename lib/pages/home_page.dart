import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

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

  @override
  Widget build(BuildContext context) {
    String test = "";
    const kGoogleApiKey = "AIzaSyBFPJ9b4hwLh_CwUAPEe8aMIGT4deavGCk";
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              myMapController = controller;
            },
          ),
          Positioned(
            top: Get.height * .10,
            child: buildProfileTile(),
          ),
          Positioned(
            top: Get.height * .30,
            child: buildTextFieldForSource(),
          ),
          Positioned(
            top: Get.height * .40,
            child: buildTextField(),
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
        types: ["(cities)"],
        radius: 1000,
        strictbounds: false,
        region: 'ph',
        context: context,
        apiKey: kGoogleApiKey,
        mode: Mode.overlay, // Mode.fullscreen
        language: "en",
        components: [new Component(Component.country, "ph")]);

    return p!.description!;
  }

  Widget buildProfileTile() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: Get.width,
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/profile-placeholder.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Good Morning, ",
                      style: GoogleFonts.varelaRound(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: "Reydan",
                      style: GoogleFonts.varelaRound(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Where are you going?",
                style: GoogleFonts.varelaRound(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  TextEditingController destinationController = TextEditingController();
  TextEditingController sourceController = TextEditingController();
  bool showSourceField = false;

  Widget buildTextField() {
    var bodyText = GoogleFonts.varelaRound(fontSize: 14);
    return Container(
      width: Get.width * .80,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: TextFormField(
        // controller: widget.textController,
        // keyboardType: widget.keyboardtype,
        controller: destinationController,
        readOnly: true,
        onTap: () async {
          String selectedPlace = await showGoogleAutoComplete();
          destinationController.text = selectedPlace;

          setState(() {
            showSourceField = true;
          });
        },
        decoration: InputDecoration(
          hintText: "Destination:",
          hintStyle: GoogleFonts.varelaRound(
            fontSize: 14,
            color: Colors.black,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.green.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.green.shade300,
            ),
          ),
          suffixIcon: const Icon(
            Icons.search,
            color: Colors.green,
          ),
        ),
        style: bodyText,
      ),
    );
  }

  Widget buildTextFieldForSource() {
    var bodyText = GoogleFonts.varelaRound(fontSize: 14);
    return Container(
      width: Get.width * .80,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: TextFormField(
        // controller: widget.textController,
        // keyboardType: widget.keyboardtype,
        controller: sourceController,
        readOnly: true,
        onTap: () async {
          String selectedPlace = await showGoogleAutoComplete();
          sourceController.text = selectedPlace;

          setState(() {
            Get.bottomSheet(
              Container(
                width: Get.width,
                height: Get.height * 0.50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Select your location:",
                      style: GoogleFonts.varelaRound(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Home address:",
                      style: GoogleFonts.varelaRound(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      width: Get.width,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
        decoration: InputDecoration(
          hintText: "From: ",
          hintStyle: GoogleFonts.varelaRound(
            fontSize: 14,
            color: Colors.black,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.green.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.green.shade300,
            ),
          ),
          suffixIcon: const Icon(
            Icons.search,
            color: Colors.green,
          ),
        ),
        style: bodyText,
      ),
    );
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
      width: Get.width * 0.65,
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

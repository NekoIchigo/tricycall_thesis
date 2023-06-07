import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tricycall_thesis/pages/home_page.dart';

import '../controller/passenger_controller.dart';

class SelectLocations extends StatefulWidget {
  final Position? currentLocation;
  const SelectLocations({
    Key? key,
    required this.currentLocation,
  }) : super(key: key);

  @override
  State<SelectLocations> createState() => _SelectLocationsState();
}

class _SelectLocationsState extends State<SelectLocations> {
  TextEditingController pickUpLocation = TextEditingController();
  TextEditingController dropOffLocation = TextEditingController();
  PassengerController passengerController = Get.find<PassengerController>();
  late SharedPreferences localStorage;

  getStorageInstance() async {
    localStorage = await SharedPreferences.getInstance();
  }

  setSourceLocation(source) async {
    localStorage.setString("source", source);
  }

  setDestinaiton(destination) async {
    localStorage.setString("destination", destination);
  }

  @override
  void initState() {
    super.initState();
    getStorageInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.green,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: Get.width * .10,
                    height: 85,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 20,
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
                          top: 36,
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
                          top: 50,
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
                    ),
                  ),
                  const SizedBox(width: 5),
                  Column(
                    children: [
                      SizedBox(
                        width: Get.width * .80,
                        child: TextField(
                          onTap: () async {
                            var result = await showGoogleAutoComplete();
                            pickUpLocation.text = result;
                            setSourceLocation(pickUpLocation.text);
                            setState(() {});
                          },
                          controller: pickUpLocation,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(5),
                            label: Text("Pick up at...",
                                style: GoogleFonts.varelaRound(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: Get.width * .80,
                        child: TextField(
                          onTap: () async {
                            if (pickUpLocation.text != "") {
                              var result = await showGoogleAutoComplete();
                              dropOffLocation.text = result;
                              setDestinaiton(dropOffLocation.text);
                              passengerController.isAssignedRoute.value = true;
                              setState(() {});
                              Get.to(() => const HomePage());
                            } else {
                              Get.snackbar("Missing input",
                                  "Please first fill up the pick up location",
                                  backgroundColor: Colors.red.shade200);
                            }
                          },
                          controller: dropOffLocation,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(5),
                            label: Text("Drop off at...",
                                style: GoogleFonts.varelaRound(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // const Divider(color: Colors.black),
            // ListTile(
            //   leading: const CircleAvatar(
            //     radius: 18,
            //     child: Icon(Icons.location_on),
            //   ),
            //   title: Text(
            //     "Current Location",
            //     style: GoogleFonts.varelaRound(
            //         fontSize: 16, fontWeight: FontWeight.bold),
            //   ),
            // ),
            // const Divider(color: Colors.black),
            // ListTile(
            //   leading: const CircleAvatar(
            //     radius: 18,
            //     child: Icon(Icons.location_on),
            //   ),
            //   title: Text(
            //     "Home Address",
            //     style: GoogleFonts.varelaRound(
            //         fontSize: 16, fontWeight: FontWeight.bold),
            //   ),
            // ),
            // const Divider(color: Colors.black),
            // ListTile(
            //   leading: const CircleAvatar(
            //     radius: 18,
            //     child: Icon(Icons.location_on),
            //   ),
            //   title: Text(
            //     "Work Address",
            //     style: GoogleFonts.varelaRound(
            //         fontSize: 16, fontWeight: FontWeight.bold),
            //   ),
            // ),
            // const Divider(color: Colors.black),
          ],
        ),
      ),
    );
  }

  Future<String> showGoogleAutoComplete() async {
    const kGoogleApiKey = "AIzaSyCbYWT5IPpryxcCqNmO_4EyFFCpIejPBf8";

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
}
// Create the polylines for showing the route between two places


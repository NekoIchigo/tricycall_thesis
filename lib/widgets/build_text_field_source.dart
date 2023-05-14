import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:tricycall_thesis/controller/auth_controller.dart';

class BuildTextFieldForSource extends StatefulWidget {
  final Function showGoogleAutoComplete;
  final Set<Marker> marker;
  final GoogleMapController? mapController;

  const BuildTextFieldForSource({
    Key? key,
    required this.showGoogleAutoComplete,
    required this.marker,
    required this.mapController,
  }) : super(key: key);

  @override
  State<BuildTextFieldForSource> createState() =>
      _BuildTextFieldForSourceState();
}

class _BuildTextFieldForSourceState extends State<BuildTextFieldForSource> {
  TextEditingController sourceController = TextEditingController();
  late LatLng destination;
  var bodyText = GoogleFonts.varelaRound(fontSize: 14);
  AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * .80,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 4,
            blurRadius: 10,
          ),
        ],
      ),
      child: TextFormField(
        // controller: widget.textController,
        // keyboardType: widget.keyboardtype,
        controller: sourceController,
        readOnly: true,
        onTap: () async {
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
                    const SizedBox(height: 5),
                    Container(
                      width: Get.width,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Manila City",
                            style: GoogleFonts.varelaRound(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Work address:",
                      style: GoogleFonts.varelaRound(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: Get.width,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Makati City",
                            style: GoogleFonts.varelaRound(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        Get.back();
                        String place = await widget.showGoogleAutoComplete();
                        sourceController.text = place;

                        List<geoCoding.Location> location =
                            await geoCoding.locationFromAddress(place);

                        destination = LatLng(
                            location.first.latitude, location.first.longitude);

                        widget.marker.add(
                          Marker(
                            markerId: MarkerId(place),
                            infoWindow: InfoWindow(
                              title: "Source: $place",
                            ),
                            position: destination,
                          ),
                        );

                        widget.mapController!.animateCamera(
                            CameraUpdate.newCameraPosition(
                                CameraPosition(target: destination, zoom: 14)));
                      },
                      child: Container(
                        width: Get.width,
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Search for Address",
                              style: GoogleFonts.varelaRound(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
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
}

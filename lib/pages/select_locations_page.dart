import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

class SelectLocations extends StatefulWidget {
  const SelectLocations({super.key});

  @override
  State<SelectLocations> createState() => _SelectLocationsState();
}

class _SelectLocationsState extends State<SelectLocations> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
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
}

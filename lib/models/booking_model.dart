import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingModel {
  String? driverId;
  String? userId;
  String? destinationText;
  String? sourceText;
  String? notes;
  String? passengerToken;
  String? paymentMethod;
  String? tripDistance;
  String? status;
  int? price;
  LatLng? destinaiton;
  LatLng? sourceLoc;

  BookingModel({
    this.driverId,
    this.userId,
    this.destinationText,
    this.sourceText,
    this.notes,
    this.passengerToken,
    this.paymentMethod,
    this.tripDistance,
    this.status,
    this.price,
    this.destinaiton,
    this.sourceLoc,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      driverId: json['driver_id'],
      userId: json['user_id'],
      destinationText: json['drop_off_text'],
      sourceText: json['pick_up_text'],
      notes: json['note_to_driver'],
      passengerToken: json['passenger_token'],
      paymentMethod: json['payment_method'],
      tripDistance: json['trip_distance'],
      status: json['status'],
      price: json['price']?.toInt(),
      destinaiton: LatLng(json['drop_off_location'].latitude,
          json['drop_off_location'].longitude),
      sourceLoc: LatLng(json['pick_up_location'].latitude,
          json['pick_up_location'].longitude),
    );
  }
}

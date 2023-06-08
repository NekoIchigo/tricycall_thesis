import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingModel {
  String? driverId;
  String? userId;
  String? chatId;
  String? destinationText;
  String? sourceText;
  String? notes;
  String? passengerToken;
  String? paymentMethod;
  String? tripDistance;
  String? status;
  int? totalPassnger;
  int? price;
  LatLng? destinaiton;
  LatLng? sourceLoc;
  Timestamp? timestamp;

  BookingModel({
    this.driverId,
    this.userId,
    this.chatId,
    this.destinationText,
    this.sourceText,
    this.notes,
    this.passengerToken,
    this.paymentMethod,
    this.tripDistance,
    this.status,
    this.totalPassnger,
    this.price,
    this.destinaiton,
    this.sourceLoc,
    this.timestamp,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      driverId: json['driver_id'],
      userId: json['user_id'],
      chatId: json['chat_id'],
      destinationText: json['drop_off_text'],
      sourceText: json['pick_up_text'],
      notes: json['note_to_driver'],
      passengerToken: json['passenger_token'],
      paymentMethod: json['payment_method'],
      tripDistance: json['trip_distance'],
      status: json['status'],
      timestamp: json['timestamp'],
      totalPassnger: json['total_passenger'] ?? 1,
      price: json['price']?.toInt(),
      destinaiton: LatLng(json['drop_off_location'].latitude,
          json['drop_off_location'].longitude),
      sourceLoc: LatLng(json['pick_up_location'].latitude,
          json['pick_up_location'].longitude),
    );
  }

  factory BookingModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BookingModel(
      driverId: data['driver_id'] as String?,
      userId: data['user_id'] as String?,
      chatId: data['chat_id'] as String?,
      destinationText: data['drop_off_text'] as String?,
      sourceText: data['pick_up_text'] as String?,
      notes: data['note_to_driver'] as String?,
      passengerToken: data['passenger_token'] as String?,
      paymentMethod: data['payment_method'] as String?,
      tripDistance: data['trip_distance'] as String?,
      status: data['status'] as String?,
      price: data['price'] as int?,
      totalPassnger: data['total_passenger'] ?? 1,
      timestamp: data['timestamp'] as Timestamp?,
      destinaiton: LatLng(data['drop_off_location'].latitude,
          data['drop_off_location'].longitude),
      sourceLoc: LatLng(data['pick_up_location'].latitude,
          data['pick_up_location'].longitude),
    );
  }
}

// TODO : Create a driver status collection to store the current online and their location

class UserModel {
  String? firstName;
  String? lastName;
  String? homeAddress;
  String? workAddress;
  String? role;
  String? email;
  String? emergencyEmail;
  String? image;

  UserModel({
    this.firstName,
    this.lastName,
    this.homeAddress,
    this.workAddress,
    this.role,
    this.email,
    this.emergencyEmail,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'homeAddress': homeAddress,
      'workAddress': workAddress,
      'role': role,
      'email': email,
      'emergencyEmail': emergencyEmail,
      'image': image,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      firstName: map['firstName'],
      lastName: map['lastName'],
      homeAddress: map['homeAddress'],
      workAddress: map['workAddress'],
      role: map['role'],
      email: map['email'],
      emergencyEmail: map['emergencyEmail'],
      image: map['image'],
    );
  }
}

// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class UserModel {
//   String? bAddress;
//   String? hAddress;
//   String? mallAddress;
//   String? name;
//   String? image;

//   LatLng? homeAddress;
//   LatLng? bussinessAddres;
//   LatLng? shoppingAddress;


//   UserModel({this.name,this.mallAddress,this.hAddress,this.bAddress,this.image});

//   UserModel.fromJson(Map<String,dynamic> json){
//     bAddress = json['business_address'];
//     hAddress = json['home_address'];
//     mallAddress = json['shopping_address'];
//     name = json['name'];
//     image = json['image'];
//     homeAddress = LatLng(json['home_latlng'].latitude, json['home_latlng'].longitude);
//     bussinessAddres = LatLng(json['business_latlng'].latitude, json['business_latlng'].longitude);
//     shoppingAddress = LatLng(json['shopping_latlng'].latitude, json['shopping_latlng'].longitude);
//   }
// }
import 'dart:convert';

class UserModel {
  String? firstName;
  String? lastName;
  // String? homeAddress;
  // String? workAddress;
  String? role;
  String? email;
  String? contactPerson;
  String? image;
  String? phoneNumber;
  String? discountImage;

  UserModel({
    // this.homeAddress,
    // this.workAddress,
    this.firstName,
    this.lastName,
    this.role,
    this.email,
    this.contactPerson,
    this.image,
    this.phoneNumber,
    this.discountImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      firstName: map['first_name'],
      lastName: map['last_name'],
      // homeAddress: map['home_address'],
      // workAddress: map['work_address'],
      role: map['role'],
      email: map['email'],
      contactPerson: map['contact_person'],
      image: map['image'],
      discountImage: map['discount_image'] ?? "",
      phoneNumber: map['phone_number'],
    );
  }
}

class DriverModel {
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? email;
  String? operatorName;
  String? bodyNumber;
  String? role;
  String? image;
  String? tricycleImage;
  String? licenseImage;

  DriverModel({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.email,
    this.operatorName,
    this.bodyNumber,
    this.role,
    this.image,
    this.tricycleImage,
    this.licenseImage,
  });

  factory DriverModel.fromJson(Map<String, dynamic> map) {
    return DriverModel(
      firstName: map['first_name'],
      lastName: map['last_name'],
      phoneNumber: map['phone_number'],
      email: map['email'],
      operatorName: map['operator_name'],
      bodyNumber: map['body_number'],
      role: map['role'],
      image: map['image'],
      tricycleImage: map['tricycle_pic_url'],
      licenseImage: map['license_url'],
    );
  }
}

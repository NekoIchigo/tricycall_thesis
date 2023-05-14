class UserModel {
  String? firstName;
  String? lastName;
  String? homeAddress;
  String? workAddress;
  String? image;

  UserModel(
    this.firstName,
    this.lastName,
    this.homeAddress,
    this.workAddress,
    this.image,
  );

  UserModel.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    homeAddress = json['home_address'];
    workAddress = json['work_address'];
    image = json['image'];
  }
}

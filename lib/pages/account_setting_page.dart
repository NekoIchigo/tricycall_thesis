import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tricycall_thesis/widgets/input_text.dart';
import 'package:regexed_validator/regexed_validator.dart';

import '../controller/passenger_controller.dart';
import '../widgets/green_button.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({super.key});

  @override
  State<AccountSettingPage> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController homeController = TextEditingController();
  TextEditingController workController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController emergencyEmailController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  PassengerController pasengerController = Get.find<PassengerController>();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool isEdit = false;

  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    firstNameController.text = pasengerController.myUser.value.firstName ?? "";
    lastNameController.text = pasengerController.myUser.value.lastName ?? "";
    emailController.text = pasengerController.myUser.value.email ?? "";
    emergencyEmailController.text =
        pasengerController.myUser.value.emergencyEmail ?? "";
    homeController.text = pasengerController.myUser.value.homeAddress ?? "";
    workController.text = pasengerController.myUser.value.workAddress ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Center(
          child: Text(
            "USER PROFILE",
            style: GoogleFonts.varelaRound(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                isEdit = !isEdit;
                setState(() {});
              },
              icon: Icon(
                isEdit ? Icons.edit_off : Icons.edit,
                size: 30,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.green,
      ),
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Form(
          key: formKey,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                width: Get.width,
                child: Container(
                  height: Get.height * .15,
                  color: Colors.green,
                ),
              ),
              Positioned(
                bottom: Get.height * .05,
                child: inputSections(),
              ),
              Positioned(
                bottom: Get.height * .68,
                child: getProfilePic(),
              ),
              Positioned(
                top: Get.height * .80,
                width: Get.width * .85,
                child: bottomButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget inputSections() {
    return Column(
      children: [
        SizedBox(
          height: Get.height * .55,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    underLinedInput(
                      firstNameController,
                      "Name",
                      "First name",
                      Get.width * .4,
                      (String? input) {
                        if (input!.isEmpty) {
                          return "A Field is Empty!";
                        }
                        if (input.length < 2) {
                          return "This Field must be more than 2 characters";
                        }
                      },
                    ),
                    underLinedInput(
                      lastNameController,
                      "",
                      "Last name",
                      Get.width * .4,
                      (String? input) {
                        if (input!.isEmpty) {
                          return "A Field is Empty!";
                        }
                        if (input.length < 2) {
                          return "This Field must be more than 2 characters";
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                underLinedInput(
                  emailController,
                  "Email",
                  "example@email.com",
                  Get.width * .8,
                  (String? input) {
                    if (input!.isEmpty) {
                      return "A Field is Empty!";
                    }
                    if (validator.email(input)) {
                      return "Invalid Email";
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                underLinedInput(
                  emergencyEmailController,
                  "Emergency Email",
                  "example@email.com",
                  Get.width * .8,
                  (String? input) {
                    if (input!.isNotEmpty) {
                      if (validator.email(input)) {
                        return "Invalid Email";
                      }
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                underLinedInput(
                  homeController,
                  "Home Address(Optional)",
                  "Tap here to select address",
                  Get.width * .8,
                  (String? input) {},
                ),
                const SizedBox(
                  height: 10,
                ),
                underLinedInput(
                  workController,
                  "Work Address(Optional)",
                  "Tap here to select address",
                  Get.width * .8,
                  (String? input) {},
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        Obx(
          () => pasengerController.isProfileUploading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: Get.width * .10),
                    child: greenButton(
                      "Next",
                      () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        if (selectedImage == null) {
                          Get.snackbar("Image empty", "Please insert image");
                        } else {
                          pasengerController.isProfileUploading(true);
                          pasengerController.storeUserInfo(
                            selectedImage,
                            firstNameController.text,
                            lastNameController.text,
                            emailController.text,
                            emergencyEmailController.text,
                            homeController.text,
                            workController.text,
                            url: pasengerController.myUser.value.image,
                          );
                        }
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  SizedBox underLinedInput(
    TextEditingController controller,
    String title,
    String hint,
    double? width,
    Function validator,
  ) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.varelaRound(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.varelaRound(
                fontSize: 14,
              ),
              border: const UnderlineInputBorder(),
            ),
            validator: (String? input) => validator(input),
          ),
        ],
      ),
    );
  }

  Widget getProfilePic() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.defaultDialog(
              title: "Upload Profile Picture",
              titleStyle: GoogleFonts.varelaRound(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              titlePadding: const EdgeInsets.all(20),
              content: Column(
                children: [
                  SizedBox(
                    width: Get.width * .50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        getImage(ImageSource.camera);
                        Get.back();
                      },
                      child: Text(
                        "From Camera",
                        style: GoogleFonts.varelaRound(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Get.width * .50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        getImage(ImageSource.gallery);
                        Get.back();
                      },
                      child: Text(
                        "From Files",
                        style: GoogleFonts.varelaRound(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                width: 2,
                color: Colors.green.shade900,
              ),
            ),
            child: selectedImage == null
                ? pasengerController.myUser.value.image != null
                    ? Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                pasengerController.myUser.value.image!),
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                          color: Colors.grey.shade400,
                        ),
                      )
                    : Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade400,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      )
                : Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      ),
                      shape: BoxShape.circle,
                      color: Colors.grey.shade400,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget bottomButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(
        isEdit ? "SAVE" : "LOG OUT",
        style: GoogleFonts.varelaRound(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

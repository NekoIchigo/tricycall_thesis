import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tricycall_thesis/widgets/input_text.dart';

import '../../controller/driver_controller.dart';
import 'verification_notice_page.dart';

class DriverApplicationPage extends StatefulWidget {
  const DriverApplicationPage({super.key});

  @override
  State<DriverApplicationPage> createState() => _DriverApplicationPageState();
}

class _DriverApplicationPageState extends State<DriverApplicationPage> {
  DriverController driverController = Get.find<DriverController>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobilePhoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController operatorNameController = TextEditingController();
  TextEditingController bodyNumberController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  File? tricycleImage, licenseImage;

  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    File? selectedImage;
    if (image != null) {
      selectedImage = File(image.path);
      return selectedImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: Get.width,
            child: Form(
              // TODO : Implement validation
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "APPLY AS DRIVER",
                      style: GoogleFonts.varelaRound(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InputText(
                    textController: firstNameController,
                    label: "First Name",
                    isPassword: false,
                    icon: Icons.abc,
                    keyboardtype: TextInputType.name,
                    validator: (String? input) {
                      // if (input!.isEmpty) {
                      //   return "A Field is Empty!";
                      // }
                      // if (input.length < 5) {
                      //   return "This Field must be more than 5 characters";
                      // }
                    },
                  ),
                  InputText(
                    textController: lastNameController,
                    label: "Last Name",
                    isPassword: false,
                    icon: Icons.abc,
                    keyboardtype: TextInputType.name,
                    validator: (String? input) {},
                  ),
                  InputText(
                    textController: mobilePhoneController,
                    label: "Mobile Phone",
                    isPassword: false,
                    icon: Icons.phone_android,
                    keyboardtype: TextInputType.number,
                    validator: (String? input) {},
                  ),
                  InputText(
                    textController: emailController,
                    label: "Email",
                    isPassword: false,
                    icon: Icons.email_rounded,
                    keyboardtype: TextInputType.emailAddress,
                    validator: (String? input) {},
                  ),
                  InputText(
                    textController: operatorNameController,
                    label: "Operator Name",
                    isPassword: false,
                    icon: Icons.person,
                    keyboardtype: TextInputType.name,
                    validator: (String? input) {
                      //
                    },
                  ),
                  InputText(
                    textController: bodyNumberController,
                    label: "Body Number(Tricycle Number)",
                    isPassword: false,
                    icon: Icons.onetwothree,
                    keyboardtype: TextInputType.name,
                    validator: (String? input) {
                      //
                    },
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: Get.width * .8,
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      onTap: () {
                        Get.defaultDialog(
                          title: "Upload Picture/File",
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
                                    tricycleImage =
                                        getImage(ImageSource.camera);
                                    setState(() {});
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
                                    tricycleImage =
                                        getImage(ImageSource.gallery);
                                    setState(() {});
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
                      title: Text(
                        "Upload License Picture/File",
                        style: GoogleFonts.varelaRound(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.upload,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: Get.width * .8,
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      onTap: () {
                        Get.defaultDialog(
                          title: "Upload Picture/File",
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
                                    licenseImage = getImage(ImageSource.camera);
                                    setState(() {});
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
                                    licenseImage =
                                        getImage(ImageSource.gallery);
                                    setState(() {});
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
                      title: Text(
                        "Upload Tricycle Picture",
                        style: GoogleFonts.varelaRound(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.upload,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "BY CREATING AN ACCOUNT YOU AGREE TO OUR",
                    style: GoogleFonts.varelaRound(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "TERMS OF SERVICE AND PRIVACY POLICY",
                    style: GoogleFonts.varelaRound(
                      fontSize: 10,
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: Get.width,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        if (licenseImage == null || tricycleImage == null) {
                          Get.snackbar("Necessary files/pictures not found!",
                              "Please upload the necessary files/pictures");
                        } else {
                          driverController.storeDriverApplication(
                            firstNameController,
                            lastNameController,
                            mobilePhoneController,
                            emailController,
                            operatorNameController,
                            bodyNumberController,
                            licenseImage,
                            tricycleImage,
                          );
                          Get.to(() => const VerificationNoticePage());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "SUBMIT",
                        style: GoogleFonts.varelaRound(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

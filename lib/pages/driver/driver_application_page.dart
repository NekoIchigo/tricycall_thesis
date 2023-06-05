import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:tricycall_thesis/widgets/input_text.dart';

import '../../controller/driver_controller.dart';

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
  String? tricyclePath, licensePath;

  getLicense(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      licensePath = image.path;
      licenseImage = File(image.path);
      setState(() {});
    }
  }

  getTricycle(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      tricyclePath = image.path;
      tricycleImage = File(image.path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
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
                SizedBox(
                  height: Get.height * .69,
                  width: Get.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        InputText(
                          textController: firstNameController,
                          label: "First Name",
                          isPassword: false,
                          icon: Icons.abc,
                          keyboardtype: TextInputType.name,
                          validator: (String? input) {
                            if (input!.isEmpty) {
                              return "This Field is Empty!";
                            }
                          },
                        ),
                        InputText(
                          textController: lastNameController,
                          label: "Last Name",
                          isPassword: false,
                          icon: Icons.abc,
                          keyboardtype: TextInputType.name,
                          validator: (String? input) {
                            if (input!.isEmpty) {
                              return "This Field is Empty!";
                            }
                          },
                        ),
                        InputText(
                          textController: emailController,
                          label: "Email",
                          isPassword: false,
                          icon: Icons.email_rounded,
                          keyboardtype: TextInputType.emailAddress,
                          validator: (String? input) {
                            if (input!.isEmpty) {
                              return "This Field is Empty!";
                            }
                            if (!validator.email(input)) {
                              return "Invalid Email";
                            }
                          },
                        ),
                        InputText(
                          textController: operatorNameController,
                          label: "Operator Name",
                          isPassword: false,
                          icon: Icons.person,
                          keyboardtype: TextInputType.name,
                          validator: (String? input) {
                            if (input!.isEmpty) {
                              return "This Field is Empty!";
                            }
                          },
                        ),
                        InputText(
                          textController: bodyNumberController,
                          label: "Body Number(Tricycle Number)",
                          isPassword: false,
                          icon: Icons.onetwothree,
                          keyboardtype: TextInputType.name,
                          validator: (String? input) {
                            if (input!.isEmpty) {
                              return "This Field is Empty!";
                            }
                          },
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: Get.width * .8,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Image(
                                        image: AssetImage(
                                            "assets/images/ph_flag.png"),
                                        width: 30,
                                        height: 50,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: Text("+63",
                                          style: GoogleFonts.varelaRound(
                                              fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 55,
                                color: Colors.black.withOpacity(0.2),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: TextField(
                                    controller: mobilePhoneController,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintStyle: GoogleFonts.varelaRound(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal),
                                      hintText: "ex. 948*******",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                                          getLicense(ImageSource.camera);
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
                                          getLicense(ImageSource.gallery);
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
                              licensePath ?? "Upload License Picture/File",
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
                                          getTricycle(ImageSource.camera);
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
                                          getTricycle(ImageSource.gallery);
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
                              tricyclePath ?? "Upload Tricycle Picture",
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
                      ],
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
                          firstNameController.text,
                          lastNameController.text,
                          mobilePhoneController.text,
                          emailController.text,
                          operatorNameController.text,
                          bodyNumberController.text,
                          licenseImage,
                          tricycleImage,
                        );
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
    );
  }
}

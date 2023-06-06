import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:regexed_validator/regexed_validator.dart';

import '../../controller/auth_controller.dart';
import '../../controller/driver_controller.dart';
import '../../widgets/input_text.dart';

class DriverAccountSettingPage extends StatefulWidget {
  const DriverAccountSettingPage({super.key});

  @override
  State<DriverAccountSettingPage> createState() => _DriverAccountSettingPageState();
}

class _DriverAccountSettingPageState extends State<DriverAccountSettingPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DriverController driverController = Get.find<DriverController>();
  AuthController authController = Get.find<AuthController>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController operatorNameController = TextEditingController();
  TextEditingController bodyNumberController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  File? tricycleImage, licenseImage;
  String? tricyclePath, licensePath;
  bool isEdit = false;

  getProfileImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

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
  void initState() {
    super.initState();
    firstNameController.text =
        driverController.driverData.value.firstName ?? "";
    lastNameController.text = driverController.driverData.value.lastName ?? "";
    emailController.text = driverController.driverData.value.email ?? "";
    operatorNameController.text =
        driverController.driverData.value.operatorName ?? "";
    bodyNumberController.text =
        driverController.driverData.value.bodyNumber ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "USER PROFILE",
          style: GoogleFonts.varelaRound(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          Visibility(
            visible: authController.isRegistered.value,
            child: Padding(
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
                top: Get.height * .20,
                child: inputSections(),
              ),
              Positioned(
                top: Get.height * .03,
                child: getProfilePic(),
              ),
              Positioned(
                top: Get.height * .80,
                width: Get.width * .85,
                child: Obx(
                  () => driverController.isProfileUploading.value
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : bottomButton(),
                ),
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
      ],
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
                        getProfileImage(ImageSource.camera);
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
                        getProfileImage(ImageSource.gallery);
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
                ? driverController.driverData.value.image != null
                    ? Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                driverController.driverData.value.image!),
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
      onPressed: () {
        if (!isEdit && authController.isRegistered.value) {
          authController.signOut();
        } else {
          if (!formKey.currentState!.validate()) {
            return;
          }
          if (selectedImage == null) {
            Get.snackbar("Image empty", "Please insert image");
          } else {
            driverController.isProfileUploading(true);
            driverController.storeDriverInfo(
              selectedImage,
              firstNameController.text,
              lastNameController.text,
              emailController.text,
              operatorNameController.text,
              bodyNumberController.text,
              tricycleImage,
              licenseImage,
              url: driverController.driverData.value.image,
              urlLcs: driverController.driverData.value.licenseImage,
              urlTrike: driverController.driverData.value.tricycleImage,
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(
        authController.isRegistered.value
            ? isEdit
                ? "SAVE"
                : "LOG OUT"
            : "REGISTER",
        style: GoogleFonts.varelaRound(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

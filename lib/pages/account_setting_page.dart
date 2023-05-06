import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tricycall_thesis/controller/auth_controller.dart';
import 'package:tricycall_thesis/pages/home_page.dart';
import 'package:tricycall_thesis/pages/login_page.dart';
import 'package:tricycall_thesis/widgets/input_text.dart';
import 'package:tricycall_thesis/widgets/text_widget.dart';
import 'package:path/path.dart' as Path;

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

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  AuthController authController = Get.find<AuthController>();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Get.height * 0.35,
                width: Get.width,
                child: Stack(
                  children: [
                    Container(
                      height: Get.height * 0.28,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(150)),
                        color: Colors.green.shade400,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: Get.height * 0.1),
                        child: Text(
                          "Account Settings",
                          style: GoogleFonts.varelaRound(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () {
                          getImage(ImageSource.gallery);
                        },
                        child: selectedImage == null
                            ? Container(
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
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    InputText(
                      textController: firstNameController,
                      label: "First Name",
                      icon: Icons.abc_rounded,
                      isPassword: false,
                      keyboardtype: TextInputType.text,
                      validator: (String? input) {
                        if (input!.isEmpty) {
                          return "A Field is Empty!";
                        }
                        if (input.length < 2) {
                          return "First Name is must be more than 2 characters";
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputText(
                      textController: lastNameController,
                      label: "Last Name",
                      icon: Icons.abc_rounded,
                      isPassword: false,
                      keyboardtype: TextInputType.text,
                      validator: (String? input) {
                        if (input!.isEmpty) {
                          return "A Field is Empty!";
                        }
                        if (input.length < 2) {
                          return "First Name is must be more than 2 characters";
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputText(
                      textController: homeController,
                      label: "Home Address(Optional)",
                      icon: Icons.home_rounded,
                      isPassword: false,
                      keyboardtype: TextInputType.text,
                      validator: (String? input) {
                        // if(input!.isEmpty){
                        //   return "A Field is Empty!";
                        // }
                        // if(input.length < 2){
                        //   return "First Name is must be more than 2 characters";
                        // }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputText(
                      textController: workController,
                      label: "Work Address(Optional)",
                      icon: Icons.work,
                      isPassword: false,
                      keyboardtype: TextInputType.text,
                      validator: (String? input) {
                        // if(input!.isEmpty){
                        //   return "A Field is Empty!";
                        // }
                        // if(input.length < 2){
                        //   return "First Name is must be more than 2 characters";
                        // }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Obx(
                      () => authController.isProfileUploading.value
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : greenButton(
                              "Submit",
                              () {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                if (selectedImage == null) {
                                  Get.snackbar(
                                      "title", "Please add your image");
                                  return;
                                }
                                authController.isProfileUploading(true);
                                authController.storeUserInfo(
                                    selectedImage!,
                                    firstNameController.text,
                                    lastNameController.text,
                                    homeController.text,
                                    workController.text);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

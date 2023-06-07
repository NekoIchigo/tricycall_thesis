import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:regexed_validator/regexed_validator.dart';

import '../controller/auth_controller.dart';
import '../controller/passenger_controller.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({super.key});

  @override
  State<AccountSettingPage> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  // TextEditingController homeController = TextEditingController();
  // TextEditingController workController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController emergencyEmailController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  PassengerController pasengerController = Get.find<PassengerController>();
  AuthController authController = Get.find<AuthController>();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  File? discountImage;
  bool isEdit = true;

  getProfileImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  getIDImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      discountImage = File(image.path);
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
        pasengerController.myUser.value.contactPerson ?? "";
    // homeController.text = pasengerController.myUser.value.homeAddress ?? "";
    // workController.text = pasengerController.myUser.value.workAddress ?? "";
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
                  !isEdit ? Icons.edit_off : Icons.edit,
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
                  () => pasengerController.isProfileUploading.value
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    underLinedInput(
                      firstNameController,
                      "Name",
                      "First name",
                      Get.width * .4,
                      !authController.isRegistered.value ? false : isEdit,
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
                      !authController.isRegistered.value ? false : isEdit,
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
                const SizedBox(height: 20),
                underLinedInput(
                  emailController,
                  "Email",
                  "example@email.com",
                  Get.width * .8,
                  !authController.isRegistered.value ? false : isEdit,
                  (String? input) {
                    if (input!.isEmpty) {
                      return "A Field is Empty!";
                    }
                    if (!validator.email(input)) {
                      return "Invalid Email";
                    }
                  },
                ),
                const SizedBox(height: 20),
                underLinedInput(
                  emergencyEmailController,
                  "Contact Person",
                  "example@email.com",
                  Get.width * .8,
                  !authController.isRegistered.value ? false : isEdit,
                  (String? input) {
                    if (input!.isNotEmpty) {
                      if (!validator.email(input)) {
                        return "Invalid Email";
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  "Upload ID for Discount",
                  style: GoogleFonts.varelaRound(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: Get.width * .8,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      !authController.isRegistered.value
                          ? Get.defaultDialog(
                              title: "Upload Image",
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
                                        getIDImage(ImageSource.camera);
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
                                        getIDImage(ImageSource.gallery);
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
                            )
                          : !isEdit
                              ? Get.defaultDialog(
                                  title: "Upload Image",
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
                                            getIDImage(ImageSource.camera);
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
                                            getIDImage(ImageSource.gallery);
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
                                )
                              : null;
                    },
                    child: discountImage == null
                        ? pasengerController.myUser.value.discountImage != null
                            ? Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(pasengerController
                                        .myUser.value.discountImage!),
                                    fit: BoxFit.cover,
                                  ),
                                  color: Colors.grey.shade400,
                                ),
                              )
                            : Text(
                                "Senior, Student, PWD ID",
                                style: GoogleFonts.varelaRound(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              )
                        : SizedBox(
                            height: 120,
                            width: 120,
                            child: Image(
                              image: FileImage(discountImage!),
                            ),
                          ),
                  ),
                ),
                // underLinedInput(
                //   homeController,
                //   "Home Address(Optional)",
                //   "Tap here to select address",
                //   Get.width * .8,
                //   (String? input) {},
                // ),
                // const SizedBox(
                //   height: 10,
                // ),
                // underLinedInput(
                //   workController,
                //   "Work Address(Optional)",
                //   "Tap here to select address",
                //   Get.width * .8,
                //   (String? input) {},
                // ),
                const SizedBox(height: 20),
              ],
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
    bool edit,
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
            readOnly: edit,
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
            !authController.isRegistered.value
                ? Get.defaultDialog(
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
                  )
                : !isEdit
                    ? Get.defaultDialog(
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
                      )
                    : null;
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
      onPressed: () {
        print(authController.isRegistered.value);
        if (isEdit && authController.isRegistered.value) {
          authController.signOut();
        } else {
          if (!formKey.currentState!.validate()) {
            return;
          }
          if (!authController.isRegistered.value) {
            if (selectedImage == null || discountImage == null) {
              Get.snackbar("Image empty", "Please insert image");
            } else {
              pasengerController.isProfileUploading(true);
              pasengerController.storeUserInfo(
                selectedImage,
                discountImage,
                firstNameController.text,
                lastNameController.text,
                // homeController.text,
                // workController.text,
                emailController.text,
                emergencyEmailController.text,
                url: pasengerController.myUser.value.image,
                discountUrl: pasengerController.myUser.value.discountImage,
              );
            }
          } else {
            pasengerController.isProfileUploading(true);
            pasengerController.storeUserInfo(
              selectedImage,
              discountImage,
              firstNameController.text,
              lastNameController.text,
              // homeController.text,
              // workController.text,
              emailController.text,
              emergencyEmailController.text,
              url: pasengerController.myUser.value.image,
              discountUrl: pasengerController.myUser.value.discountImage,
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
            ? !isEdit
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

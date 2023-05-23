import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tricycall_thesis/widgets/input_text.dart';

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
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Form(
          key: formKey,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: Get.width,
                  height: Get.height * .70,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00bf63),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(150),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: Get.height * .18,
                      ),
                      SingleChildScrollView(
                        child: inputSections(),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: Get.height * .55,
                child: getProfilePic(),
              ),
              Positioned(
                bottom: Get.height * .83,
                width: Get.width * .50,
                child: Image.asset("assets/images/title.png"),
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
          height: Get.height * .40,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
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
                      return "This Field must be more than 2 characters";
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
                      return "This Field must be more than 2 characters";
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                InputText(
                  textController: emailController,
                  label: "Email",
                  icon: Icons.email_rounded,
                  isPassword: false,
                  keyboardtype: TextInputType.text,
                  validator: (String? input) {
                    if (input!.isEmpty) {
                      return "A Field is Empty!";
                    }
                    if (input.length < 5) {
                      return "This Field must be more than 5 characters";
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                InputText(
                  textController: emergencyEmailController,
                  label: "Emergency Email",
                  icon: Icons.abc_rounded,
                  isPassword: false,
                  keyboardtype: TextInputType.text,
                  validator: (String? input) {
                    // if (input!.isEmpty) {
                    //   return "A Field is Empty!";
                    // }
                    // if (input.length < 2) {
                    //   return "First Name is must be more than 2 characters";
                    // }
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
                  validator: (String? input) {},
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
                  validator: (String? input) {},
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
                        // if (!formKey.currentState!.validate()) {
                        //   return;
                        // }
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
        const SizedBox(height: 20),
        Text(
          "Profile",
          style: GoogleFonts.varelaRound(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        )
      ],
    );
  }
}

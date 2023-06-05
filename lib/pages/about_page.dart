import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String paragh1 =
      "Welcome to TricyCall, an Android-based ride-hailing application designed specifically for subdivision tricycle drivers. TricyCall is a result of our thesis project developed by students from the Technological University of the Philippines.";
  String paragh2 =
      "At TricyCall, we aim to provide a convenient and efficient transportation solution for residents of Pleasant Hills, a vibrant neighborhood located in San Jose del Monte. Our app connects passengers with reliable tricycle drivers, offering a seamless and hassle-free riding experience within the subdivision.";
  String paragh3 =
      "We understand the unique needs of subdivision tricycle drivers and the importance of safe and reliable transportation for residents. TricyCall brings together technology, convenience, and affordability to create a platform that benefits both passengers and drivers alike.";
  String paragh4 =
      "With TricyCall, you can book your tricycle ride with just a few taps on your smartphone. Our user-friendly interface ensures a seamless booking process, while our dedicated drivers are committed to providing excellent service, ensuring your comfort and safety throughout your journey.";
  String paragh5 =
      "Experience the convenience of TricyCall and enjoy stress-free rides within Pleasant Hills. Download the TricyCall app today and start your journey with us!";

  final Uri _url = Uri.parse('https://tricycall.online');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        title: Text(
          "ABOUT",
          style: GoogleFonts.varelaRound(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: Get.width,
            height: Get.height * .85,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  width: Get.width,
                  height: Get.height * .25,
                  child: const Image(
                    image: AssetImage("assets/images/about_image.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: Get.height * .13,
                  width: Get.width * .40,
                  height: Get.height * .18,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white,
                    ),
                    child: const Image(
                      image: AssetImage("assets/images/logo.png"),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Positioned(
                  top: Get.height * .3,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Image(
                      image: const AssetImage("assets/images/title.png"),
                      width: Get.width * .7,
                      height: 150,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Positioned(
                  top: Get.height * .5,
                  width: Get.width * .8,
                  height: Get.height * .15,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          paragh1,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.varelaRound(),
                        ),
                        Text(
                          paragh2,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.varelaRound(),
                        ),
                        Text(
                          paragh3,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.varelaRound(),
                        ),
                        Text(
                          paragh4,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.varelaRound(),
                        ),
                        Text(
                          paragh5,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.varelaRound(),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: Get.height * .65,
                  child: InkWell(
                    onTap: () {
                      _launchUrl();
                    },
                    child: Container(
                      width: Get.width * .8,
                      height: 150,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage("assets/images/link_image.png"),
                          fit: BoxFit.fitWidth,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Padding(
                          padding:
                              EdgeInsets.only(right: Get.width * .15, top: 10),
                          child: Text(
                            "WEBSITE LINK",
                            style: GoogleFonts.varelaRound(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

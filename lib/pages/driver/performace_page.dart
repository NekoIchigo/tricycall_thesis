import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
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
            color: Colors.white,
          ),
        ),
        title: Text(
          "PERFORMANCE",
          style: GoogleFonts.varelaRound(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: Get.height * .80,
          width: Get.width,
          child: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: Get.width * .40,
                          height: 50,
                          child: ListView.builder(
                            itemCount: 5,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Icon(
                                Icons.star,
                                color: Colors.yellow.shade700,
                              );
                            },
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name of User",
                              style: GoogleFonts.varelaRound(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Date and Time",
                              style: GoogleFonts.varelaRound(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.defaultDialog(
                        title: "RIDE HISTORY",
                        titleStyle: GoogleFonts.varelaRound(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        content: Column(
                          children: [
                            Text(
                              "PICK UP LOCATION",
                              style: GoogleFonts.varelaRound(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "DROP OFF LOCATION",
                              style: GoogleFonts.varelaRound(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Text(
                                  "Date Time: ",
                                  style: GoogleFonts.varelaRound(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Expanded(child: SizedBox()),
                                Text(
                                  "MAY 17 2023, 9:20 AM",
                                  style: GoogleFonts.varelaRound(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  "Amount: ",
                                  style: GoogleFonts.varelaRound(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Expanded(child: SizedBox()),
                                Image.asset(
                                  "assets/images/peso_icon.png",
                                  width: 12,
                                  fit: BoxFit.cover,
                                ),
                                Text(
                                  "250",
                                  style: GoogleFonts.varelaRound(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: Get.width,
                              height: 3,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "DRIVER NAME",
                              style: GoogleFonts.varelaRound(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        confirm: Container(
                          width: Get.width * .75,
                          padding: const EdgeInsets.only(bottom: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            child: Text(
                              "OKAY",
                              style: GoogleFonts.varelaRound(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.black),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

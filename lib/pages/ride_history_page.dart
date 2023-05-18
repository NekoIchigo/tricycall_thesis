import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({super.key});

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
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
          "RIDE HISTORY",
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
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                title: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pick Up Location",
                          style: GoogleFonts.varelaRound(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Drop off Location",
                          style: GoogleFonts.varelaRound(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Expanded(child: SizedBox()),
                    Image.asset(
                      "assets/images/peso_icon.png",
                      width: 15,
                      fit: BoxFit.cover,
                    ),
                    Text(
                      "250",
                      style: GoogleFonts.varelaRound(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Date, Time",
                    style: GoogleFonts.varelaRound(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
                trailing: const Icon(Icons.navigate_next_rounded),
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
                      ));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class RideInfo {
  String? sourceLocation;
  String? destination;
  DateTime? dateTime;
  int? price;
  String? driverName;

  RideInfo(
    this.sourceLocation,
    this.destination,
    this.dateTime,
    this.price,
    this.driverName,
  );

  Map<String, dynamic> toJson() {
    return {
      'sourceLocation': sourceLocation,
      'destination': destination,
      'dateTime': dateTime?.millisecondsSinceEpoch,
      'price': price,
      'driverName': driverName,
    };
  }

  factory RideInfo.fromJson(Map<String, dynamic> json) {
    return RideInfo(
      json['sourceLocation'],
      json['destination'],
      json['dateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dateTime'])
          : null,
      json['price']?.toInt(),
      json['driverName'],
    );
  }
}

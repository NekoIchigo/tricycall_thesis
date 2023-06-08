import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tricycall_thesis/controller/auth_controller.dart';
import 'package:tricycall_thesis/controller/passenger_controller.dart';
import 'package:tricycall_thesis/models/booking_model.dart';

import '../models/user_model.dart';

class RideHistory extends StatefulWidget {
  final String userID;
  final String userRole;
  const RideHistory({
    Key? key,
    required this.userID,
    required this.userRole,
  }) : super(key: key);

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  PassengerController passengerController = Get.find<PassengerController>();
  AuthController authController = Get.find<AuthController>();

  BookingModel bookingData = BookingModel();
  List<BookingModel> allBookings = [];
  bool isListEmpty = true;
  UserModel userData = UserModel();

  getAllUserBookingData() async {
    var id = widget.userRole == "passenger" ? "user_id" : "driver_id";

    var querySnapshot = await FirebaseFirestore.instance
        .collection("bookings")
        .where(id, isEqualTo: widget.userID)
        .orderBy("timestamp", descending: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        BookingModel booking = BookingModel.fromSnapshot(doc);
        allBookings.add(booking);
      }
      isListEmpty = false;
      setState(() {});
    } else {
      isListEmpty = true;
      setState(() {});
    }
  }

  getUserData(id) async {
    userData = await authController.getUserData(id);
  }

  @override
  void initState() {
    super.initState();
    getAllUserBookingData();
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
          child: isListEmpty
              ? Center(
                  child: Text(
                    "You have not make a ride yet. Start booking now!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.varelaRound(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: allBookings.length,
                  itemBuilder: (context, index) {
                    // get the user data
                    String id = widget.userRole == "passenger"
                        ? allBookings[index].driverId!
                        : allBookings[index].userId!;
                    getUserData(id);

                    DateTime dateTime = allBookings[index].timestamp!.toDate();
                    String formattedDateTime =
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          title: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: Get.width * .65,
                                    child: Text(
                                      allBookings[index].sourceText ??
                                          "Pick Up Location",
                                      style: GoogleFonts.varelaRound(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: Get.width * .65,
                                    child: Text(
                                      allBookings[index].destinationText ??
                                          "Drop off Location",
                                      style: GoogleFonts.varelaRound(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
                                "${allBookings[index].price ?? "Price"}",
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
                              formattedDateTime,
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
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              content: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "From: ",
                                        style: GoogleFonts.varelaRound(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          allBookings[index].sourceText ??
                                              "PICK UP LOCATION",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.varelaRound(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(color: Colors.grey),
                                  Row(
                                    children: [
                                      Text(
                                        "To: ",
                                        style: GoogleFonts.varelaRound(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          allBookings[index].destinationText ??
                                              "DROP OFF LOCATION",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.varelaRound(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(color: Colors.grey),
                                  Row(
                                    children: [
                                      Text(
                                        "Date Time: ",
                                        style: GoogleFonts.varelaRound(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Expanded(child: SizedBox()),
                                      Text(
                                        formattedDateTime,
                                        style: GoogleFonts.varelaRound(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
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
                                        "${allBookings[index].price ?? "Price"}",
                                        style: GoogleFonts.varelaRound(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        "Total Passenger: ",
                                        style: GoogleFonts.varelaRound(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Expanded(child: SizedBox()),
                                      Text(
                                        "${allBookings[index].totalPassnger ?? "Total Passenger"}",
                                        style: GoogleFonts.varelaRound(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        "Driver name: ",
                                        style: GoogleFonts.varelaRound(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Expanded(child: SizedBox()),
                                      Text(
                                        userData.firstName ?? "Driver Name",
                                        style: GoogleFonts.varelaRound(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
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
                                ],
                              ),
                              confirm: Container(
                                width: Get.width * .75,
                                padding: const EdgeInsets.only(bottom: 20),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20))),
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
                        const Divider(color: Colors.grey),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

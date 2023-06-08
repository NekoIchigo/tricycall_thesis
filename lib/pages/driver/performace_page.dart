import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/booking_model.dart';
import '../../models/user_model.dart';

class PerformancePage extends StatefulWidget {
  final String userId;
  const PerformancePage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  bool isListEmpty = true;
  List<RatingModel> ratingList = [];
  BookingModel bookingData = BookingModel();
  var totalRating = 0;
  double aveRating = 0.0;

  getAllRating() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection("ratings")
        .where("driver_id", isEqualTo: widget.userId.trim())
        .orderBy("rating_value", descending: true)
        .get();
    print(querySnapshot.docs.length);
    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        // print(doc.data().toString());
        ratingList.add(RatingModel.fromJson(doc.data()));
        totalRating += doc.data()["rating_value"] as int;
      }
      isListEmpty = false;
      setState(() {});
    } else {
      isListEmpty = true;
      setState(() {});
    }
    aveRating = totalRating / ratingList.length;
  }

  getBookingData(bookingId) async {
    var bookingSnapshot = await FirebaseFirestore.instance
        .collection("bookings")
        .doc(bookingId.trim())
        .get();
    if (bookingSnapshot.exists) {
      bookingData = BookingModel.fromJson(bookingSnapshot.data()!);
    }
  }

  @override
  void initState() {
    super.initState();
    getAllRating();
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
          "PERFORMANCE",
          style: GoogleFonts.varelaRound(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: Get.height * .05),
            height: Get.height * .26,
            width: Get.width,
            child: Column(
              children: [
                Text(
                  "RATING SCORE: ${aveRating.toStringAsFixed(2)}",
                  style: GoogleFonts.varelaRound(
                    fontSize: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: RatingBar.builder(
                    ignoreGestures: true,
                    initialRating: aveRating,
                    allowHalfRating: true,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {},
                  ),
                ),
                Text(
                  "This is your average performance...",
                  style: GoogleFonts.varelaRound(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.black),
          SingleChildScrollView(
            child: SizedBox(
              height: Get.height * .55,
              width: Get.width,
              child: isListEmpty
                  ? Center(
                      child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "No Ratings yet start accepting booking to receive a rating...",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.varelaRound(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ))
                  : ListView.builder(
                      itemCount: ratingList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                              title: RatingBar.builder(
                                ignoreGestures: true,
                                itemSize: 25,
                                initialRating:
                                    ratingList[index].ratingVal!.toDouble(),
                                allowHalfRating: true,
                                direction: Axis.horizontal,
                                itemCount: 5,
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {},
                              ),
                              subtitle: Container(
                                padding: EdgeInsets.only(left: Get.width * .02),
                                width: Get.width * .75,
                                child: Text(
                                  "Comment: ${ratingList[index].comment}",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.varelaRound(),
                                ),
                              ),
                              trailing: const Icon(Icons.navigate_next),
                              onTap: () {
                                getBookingData(ratingList[index].bookingId);
                                print(bookingData.timestamp);
                                DateTime dateTime =
                                    bookingData.timestamp!.toDate();
                                String formattedDateTime =
                                    DateFormat('yyyy-MM-dd HH:mm:ss')
                                        .format(dateTime);
                                Get.defaultDialog(
                                  title: "RATING INFORMATION",
                                  titleStyle: GoogleFonts.varelaRound(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  content: Column(
                                    children: [
                                      RatingBar.builder(
                                        ignoreGestures: true,
                                        initialRating: ratingList[index]
                                            .ratingVal!
                                            .toDouble(),
                                        allowHalfRating: true,
                                        direction: Axis.horizontal,
                                        itemCount: 5,
                                        itemPadding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (rating) {},
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Text(
                                            "Comment: ",
                                            style: GoogleFonts.varelaRound(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Flexible(
                                            child: Text(
                                              "${ratingList[index].comment}",
                                              style: GoogleFonts.varelaRound(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Text(
                                            "DateTime: ",
                                            style: GoogleFonts.varelaRound(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Flexible(
                                            child: Text(
                                              formattedDateTime,
                                              style: GoogleFonts.varelaRound(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                  confirm: Container(
                                    width: Get.width * .75,
                                    padding: const EdgeInsets.only(bottom: 20),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
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
                            const Divider(color: Colors.black),
                          ],
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class RatingModel {
  String? bookingId;
  String? driverId;
  String? comment;
  int? ratingVal;

  RatingModel({
    this.bookingId,
    this.driverId,
    this.comment,
    this.ratingVal,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      bookingId: json['booking_id'],
      driverId: json['driver_id'],
      comment: json['comment_value'],
      ratingVal: json['rating_value']?.toInt(),
    );
  }
}

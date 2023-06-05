import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tricycall_thesis/pages/driver/driver_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/booking_model.dart';
import '../models/user_model.dart';

class ChatPage extends StatefulWidget {
  final String senderRole;
  final String bookingId;
  const ChatPage({
    Key? key,
    required this.senderRole,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();

  BookingModel bookingInfo = BookingModel();
  String? senderId, receiverId;
  UserModel receiverData = UserModel();
  bool _hasCallSupport = false;

  getBookingInfoget() async {
    var result = await FirebaseFirestore.instance
        .collection("bookings")
        .doc(widget.bookingId)
        .get();

    if (result.exists) {
      bookingInfo = BookingModel.fromJson(result.data()!);
      senderId = widget.senderRole == "passenger"
          ? bookingInfo.userId
          : widget.senderRole == "driver"
              ? bookingInfo.driverId
              : "invalid_role";
      receiverId = widget.senderRole == "passenger"
          ? bookingInfo.driverId
          : widget.senderRole == "driver"
              ? bookingInfo.userId
              : "invalid_role";

      if (authController.getUserData(receiverId!) != null) {
        receiverData = await authController.getUserData(receiverId!);
        setState(() {});
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  void initState() {
    super.initState();
    getBookingInfoget();
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
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
          receiverData.firstName ?? "",
          style: GoogleFonts.varelaRound(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _hasCallSupport
                ? () => setState(() {
                      _makePhoneCall(receiverData.phoneNumber!);
                    })
                : null,
            icon: const Icon(Icons.phone),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(bookingInfo.chatId) // Replace with your chat ID
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true, // Set reverse property to true
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          messages[index].data() as Map<String, dynamic>;
                      return message['sender_id'] == senderId
                          ? Container(
                              margin:
                                  EdgeInsets.fromLTRB(Get.width * .5, 2, 5, 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade300,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                title: Text(
                                  message['content'],
                                  style: GoogleFonts.varelaRound(
                                      color: Colors.white),
                                ),
                              ),
                            )
                          : Container(
                              margin:
                                  EdgeInsets.fromLTRB(5, 2, Get.width * .5, 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                title: Text(
                                  message['content'],
                                  style: GoogleFonts.varelaRound(),
                                ),
                              ),
                            );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(color: Colors.green),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      authController.addMessageToChat(
                        bookingInfo.chatId!,
                        senderId!,
                        messageController.text,
                      ); // Replace with your send message function
                      messageController.text = "";
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

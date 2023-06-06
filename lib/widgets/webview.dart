import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../controller/passenger_controller.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  PassengerController passengerController = PassengerController();
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    bool isLoading = true;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                passengerController.isUrlLoading.value = false;
                print("loading starts, $isLoading");
                setState(() {});
              },
            ),
            Obx(
              () => passengerController.isUrlLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.green.shade400,
                radius: 30,
                child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.home,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

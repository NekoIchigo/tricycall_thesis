import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _expandedPanel = '';

  void _handleExpansionChanged(String panelId, bool isExpanded) {
    setState(() {
      if (isExpanded) {
        _expandedPanel = panelId;
      } else {
        _expandedPanel = '';
      }
    });
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
          "SETTINGS",
          style: GoogleFonts.varelaRound(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            width: Get.width,
            child: Column(
              children: [
                Container(
                  width: Get.width * .9,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFDADADA),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ExpandablePanel(
                    title: "TricyCall Terms and Conditions",
                    content: termsOfService(),
                    isExpanded: _expandedPanel == 'announcements',
                    onExpansionChanged: (isExpanded) {
                      _handleExpansionChanged('employmentDetails', isExpanded);
                    },
                  ),
                ),
                Container(
                  width: Get.width * .9,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFDADADA),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ExpandablePanel(
                    title: "TricyCall Privacy Policy",
                    content: privacyAct(),
                    isExpanded: _expandedPanel == 'announcements',
                    onExpansionChanged: (isExpanded) {
                      _handleExpansionChanged('employmentDetails', isExpanded);
                    },
                  ),
                ),
                Container(
                  width: Get.width * .9,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFDADADA),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ExpandablePanel(
                    title: "Version",
                    content: Text(
                      "Version  1.0",
                      style: GoogleFonts.varelaRound(),
                    ),
                    isExpanded: _expandedPanel == 'announcements',
                    onExpansionChanged: (isExpanded) {
                      _handleExpansionChanged('employmentDetails', isExpanded);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget termsOfService() {
    String paragh1 =
        "Please read these terms and conditions carefully before using the TricyCall mobile application.";
    String paragh2 =
        "By downloading, installing, and using the TricyCall app, you agree to comply with these terms and conditions. If you do not agree with any of the provisions stated herein, please refrain from using the application.";
    String paragh3 =
        "As a user of TricyCall, you are responsible for providing accurate and up-to-date information during registration. You must also adhere to the applicable laws and regulations governing transportation services.";
    String paragh4 =
        "TricyCall strives to provide uninterrupted and reliable service. However, we do not guarantee the continuous availability of the app and may temporarily suspend or terminate the service for maintenance or other reasons.";
    String paragh5 =
        "We value your privacy and handle your personal data in accordance with our Privacy Policy. By using TricyCall, you consent to the collection, use, and disclosure of your information as described in the Privacy Policy.";
    String paragh6 =
        "The TricyCall app and all its contents, including logos, trademarks, and intellectual property, are owned by TricyCall or its affiliates. You agree not to reproduce, modify, or distribute any of the app's content without prior written permission.";
    String paragh7 =
        "TricyCall shall not be liable for any direct, indirect, incidental, or consequential damages arising from your use of the app or any third-party services accessed through the app.";
    String paragh8 =
        "These terms and conditions shall be governed by and construed in accordance with the laws of the jurisdiction in which TricyCall operates.";
    String paragh9 =
        "By using the TricyCall app, you acknowledge that you have read, understood, and agreed to these terms and conditions. If you have any questions or concerns, please contact us at support@tricycall.com.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          paragh1,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "1. Acceptance of Terms",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh2,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "2. User Responsibilities",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh3,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "3. Service Availability",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh4,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "4. Privacy and Data Protection",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh5,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "5. Intellectual Property",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh6,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "6. Limitation of Liability",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh7,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "7. Governing Law",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh8,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          paragh9,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
      ],
    );
  }

  Widget privacyAct() {
    String paragh1 =
        "This Privacy Policy describes how TricyCall collects, uses, and protects the personal information you provide when using the TricyCall mobile application.";
    String paragh2 =
        "TricyCall collects personal information such as your name, contact details, and location when you register for an account or use the app's features. We may also collect non-personal information such as device information and usage statistics.";
    String paragh3 =
        "We use the collected information to provide and improve our services, customize your experience, and communicate with you. We may also use the information for analytics, research, and marketing purposes.";
    String paragh4 =
        "TricyCall may share your personal information with trusted third-party service providers to facilitate the app's functionality. We do not sell, rent, or trade your personal information to third parties for marketing purposes without your consent.";
    String paragh5 =
        "We implement industry-standard security measures to protect your personal information from unauthorized access, disclosure, alteration, or destruction. However, please note that no method of transmission over the internet or electronic storage is completely secure.";
    String paragh6 =
        "TricyCall uses cookies and similar tracking technologies to enhance your experience, gather information about usage patterns, and deliver personalized content. You may disable cookies in your browser settings, but this may affect the functionality of the app.";
    String paragh7 =
        "The TricyCall app may contain links to third-party websites or services. We are not responsible for the privacy practices or content of these external sites. We recommend reviewing the privacy policies of those websites before providing any personal information.";
    String paragh8 =
        "TricyCall reserves the right to update or modify this Privacy Policy at any time. We will notify you of any changes.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          paragh1,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "1. Information Collection",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh2,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "2. Use of Information",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh3,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "3. Information Sharing",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh4,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "4. Data Security",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh5,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "5. Cookies and Tracking Technologies",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh6,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "6. Third-Party Links",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh7,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
        Text(
          "7. Updates to the Privacy Policy",
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        Text(
          paragh8,
          textAlign: TextAlign.justify,
          style: GoogleFonts.varelaRound(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class ExpandablePanel extends StatefulWidget {
  final String title;
  final Widget content;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const ExpandablePanel({
    Key? key,
    required this.title,
    required this.content,
    this.isExpanded = false,
    required this.onExpansionChanged,
  }) : super(key: key);

  @override
  State<ExpandablePanel> createState() => _ExpandablePanelState();
}

class _ExpandablePanelState extends State<ExpandablePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    final isExpanded = !_animationController.isDismissed;
    widget.onExpansionChanged(!isExpanded);
    if (isExpanded) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _toggleExpanded,
            child: ListTile(
              title: Text(
                widget.title,
                style: GoogleFonts.varelaRound(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: RotationTransition(
                turns:
                    Tween(begin: 0.0, end: 0.5).animate(_animationController),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _animation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.content,
            ),
          ),
        ],
      ),
    );
  }
}

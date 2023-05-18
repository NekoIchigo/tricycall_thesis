import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class InputText extends StatefulWidget {
  final TextEditingController textController;
  final String label;
  final bool isPassword;
  final IconData icon;
  final TextInputType keyboardtype;
  final Function validator;

  const InputText({
    Key? key,
    required this.textController,
    required this.label,
    required this.isPassword,
    required this.icon,
    required this.keyboardtype,
    required this.validator,
  }) : super(key: key);

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  bool _isObscure = true;

  _togglePasswordView() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color secondaryColor = Theme.of(context).colorScheme.secondary;
    var bodyText = GoogleFonts.varelaRound(
      fontSize: 14,
      color: Colors.black,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: SizedBox(
        width: Get.width * .8,
        child: TextFormField(
          validator: (String? input) => widget.validator(input),
          controller: widget.textController,
          keyboardType: widget.keyboardtype,
          obscureText: widget.isPassword ? _isObscure : false,
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: bodyText,
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: secondaryColor),
            ),
            suffixIcon: widget.isPassword
                ? InkWell(
                    onTap: _togglePasswordView,
                    child: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF888888),
                    ),
                  )
                : Icon(widget.icon, color: Colors.green.shade400),
          ),
          style: bodyText,
        ),
      ),
    );
  }
}

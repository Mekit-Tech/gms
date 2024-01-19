import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IndianPhoneNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const IndianPhoneNumberInput(
      {super.key, required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        hintText: 'Enter Indian phone number',
        counterText: '',
      ),
      onChanged: (value) {
        if (value.length == 10) {
          // Input has valid Indian phone number
          // Perform your desired action here
        }
      },
    );
  }
}

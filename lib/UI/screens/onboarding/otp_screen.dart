import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpCode;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: false,
        title: SizedBox(
          width: 45,
          child: Image.asset('assets/icons/mekitblacklogo.png'),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 200,
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          splashColor: Colors.greenAccent.shade700,
          hoverColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: () {},
          child: const Icon(
            Icons.arrow_forward,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "OTP Verification",
              style: TextStyle(
                color: Colors.black,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Enter OTP sent to your phone number.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Pinput(
              length: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              showCursor: true,
              defaultPinTheme: PinTheme(
                textStyle: const TextStyle(fontSize: 20),
                width: 50,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black38),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  otpCode = value;
                });
              },
            ),
            const SizedBox(height: 40),
            const Text("Resend OTP"),
          ],
        ),
      ),
    );
  }
}

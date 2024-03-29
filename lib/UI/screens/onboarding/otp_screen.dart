import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mekit_gms/UI/screens/home_screen.dart';
import 'package:mekit_gms/UI/screens/onboarding/garage_onboarding_screen.dart';
import 'package:mekit_gms/provider/auth_provider.dart';
import 'package:mekit_gms/utils/utils.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  int start = 30; // OTP Timer
  String? otpCode;
  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
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
          onPressed: () {
            if (otpCode != null) {
              verifyOtp(context, otpCode!);
            } else {
              showSnackBar(context, "Enter 6 digit code");
            }
          },
          child: const Icon(
            Icons.arrow_forward,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.black45,
                ),
              )
            : Center(
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
                      onCompleted: (value) {
                        setState(() {
                          otpCode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      child: Text(
                        "Resend OTP in $start secounds",
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // verify otp
  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtp(
        context: context,
        verificationId: widget.verificationId,
        userOtp: userOtp,
        onSucsess: () {
          // Check weather Garage exists in the database
          ap.checkExistingUser().then((value) async {
            if (value == true) {
              // Garage exists in our database
              ap.getDataFromFirestore().then(
                    (value) => ap.saveGarageDatatoSP().then(
                          (value) => ap.setSignIn().then(
                                (value) => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                    (route) => false),
                              ),
                        ),
                  );
            } else {
              // New Garage
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OnboardingScreen()),
                  (route) => false);
            }
          });
        });
  }
}

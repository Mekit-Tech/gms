import 'package:flutter/material.dart';
import 'package:mekit_gms/UI/screens/home_screen.dart';
import 'package:mekit_gms/UI/screens/onboarding/register_screen.dart';
import 'package:mekit_gms/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: false,
        title: SizedBox(
          width: 45,
          child: Image.asset('assets/icons/mekitblacklogo.png'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Get Started!',
              style: TextStyle(fontSize: 24.0),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton (
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                // Fetching data from shared prefs when signed in
                if (ap.isSignedIn == true) {
                  await ap.getDataFromSP().whenComplete(
                        () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          ),
                        },
                      );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                }
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}

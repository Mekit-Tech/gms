import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome Screen with Button',
      home: Scaffold(
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
                'Welcome to my app!',
                style: TextStyle(fontSize: 24.0),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                child: const Text('Get Started'),
                onPressed: () {
                  // Add your action here
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

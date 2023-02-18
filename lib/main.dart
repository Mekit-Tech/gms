import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mekit_gms/UI/screens/home_screen.dart';
import 'UI/screens/add_new.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      routes: {
        'homepage': (context) => const HomeScreen(),
        'newcustomer': (context) => const AddNew(),
      },
    );
  }
}

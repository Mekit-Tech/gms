import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mekit_gms/UI/screens/home_screen.dart';
import 'package:mekit_gms/UI/screens/onboarding/welcome_screen.dart';
import 'package:mekit_gms/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'UI/screens/new_customer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const WelcomeScreen(),
        routes: {
          'homepage': (context) => const HomeScreen(),
          'newcustomer': (context) => const AddNew(),
        },
      ),
    );
  }
}


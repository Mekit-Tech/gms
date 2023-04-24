import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mekit_gms/UI/screens/customer_profile_screen.dart';
import 'package:mekit_gms/UI/widgets/card_widget.dart';

// New Home

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          actions: [
            const Padding(
              padding: EdgeInsets.only(top: 24, right: 10),
              child: Text(
                "0",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 55,
                child: Image.asset(
                  'assets/icons/car.png',
                ),
              ),
            ),
          ],
          bottom: TabBar(
            padding: const EdgeInsets.only(left: 20, right: 20),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black),
            ),
            tabs: [
              Tab(
                height: 40,
                child: Container(
                  margin: const EdgeInsets.only(right: 10, left: 10),
                  child: const Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.home_outlined),
                  ),
                ),
              ),
              Tab(
                height: 40,
                child: Container(
                  margin: const EdgeInsets.only(right: 10, left: 10),
                  child: const Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.payments_outlined),
                  ),
                ),
              ),
              Tab(
                height: 40,
                child: Container(
                  margin: const EdgeInsets.only(right: 10, left: 10),
                  child: const Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.people),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Theme(
          data: ThemeData(
            colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
          ),
          child: FloatingActionButton(
            child: const Icon(
              Icons.add,
            ),
            onPressed: () {
              setState(() {
                Navigator.of(context).pushNamed('newcustomer');
              });
            },
          ),
        ),
      ),
    );
  }
}

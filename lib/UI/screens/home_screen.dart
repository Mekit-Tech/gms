import 'package:flutter/material.dart';
import 'package:mekit_gms/UI/screens/tabs/addjobs.dart';
import 'package:mekit_gms/UI/screens/tabs/contacts.dart';
import 'package:mekit_gms/UI/screens/tabs/finance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("cars").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  print("Error: ${snapshot.error}");
                  return const Icon(Icons.error_outline);
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  print("Connection state is waiting.");
                  return const CircularProgressIndicator();
                }

                final int carCount = snapshot.data!.docs.length;
                print("Car Count: $carCount"); // Print the count for debugging

                return Padding(
                  padding: const EdgeInsets.only(top: 7.0, right: 20),
                  child: Text(
                    carCount.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                );
              },
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
                    child: Icon(Icons.people),
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
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              Navigator.of(context).pushNamed('newcustomer');
            });
          },
          backgroundColor: Colors.black,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ), // Set background color directly
        ),
        body: const TabBarView(children: [
          AddJobs(),
          CustomerContacts(),
          MoneyScreen(),
        ]),
      ),
    );
  }
}

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
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("cars").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            //checking the connection state, if we still load the data we display a progress bar
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  children: snapshot.data!.docs
                      .map((cars) => noteCard(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VehicleProfile(cars),
                              ),
                            );
                          }, cars))
                      .toList(),
                ),
              );
            }
            return const Text(
              "You have no cars",
            );
          },
        ),
      ),
    );
  }
}

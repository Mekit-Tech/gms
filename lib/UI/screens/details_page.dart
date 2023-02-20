import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VehicleProfile extends StatefulWidget {
  VehicleProfile(this.doc, {Key? key}) : super(key: key);
  QueryDocumentSnapshot doc;
  @override
  State<VehicleProfile> createState() => _VehicleProfileState();
}

class _VehicleProfileState extends State<VehicleProfile> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
          ]),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.doc["customer_name"],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.doc["rto_number"],
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () {
                        // Add button onPressed action here
                      },
                    ),
                  ],
                ),
              ),
            ),

            // TODO:
          ],
        ),
      ),
    );
  }
}

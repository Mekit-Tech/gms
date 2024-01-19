import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mekit_gms/UI/screens/pdf_generator.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class VehicleProfile extends StatefulWidget {
  VehicleProfile(this.doc, {Key? key}) : super(key: key);
  QueryDocumentSnapshot doc;
  @override
  State<VehicleProfile> createState() => _VehicleProfileState();
}

class _VehicleProfileState extends State<VehicleProfile> {
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
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("cars").snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                print("Error: ${snapshot.error}");
                return Icon(Icons.error_outline);
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                print("Connection state is waiting.");
                return CircularProgressIndicator();
              }

              final int carCount = snapshot.data!.docs.length;

              return Padding(
                padding: const EdgeInsets.only(top: 22.0, right: 20),
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
          onPressed: () async {
            // Add Logic

            // ignore: unused_local_variable
            var data = await generatePdf(widget.doc);
            Directory appDocDirectory =
                await getApplicationDocumentsDirectory();
            String dirPath = '${appDocDirectory.path}/pdfs/';
            await File('$dirPath/file1.pdf').create(recursive: true);
            String filePath = 'root.path/file1.pdf';
            print(filePath);
          },
          child: const Icon(
            Icons.arrow_right_outlined,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Column(
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
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Parts & Labor",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        onPressed: () {
                          // Add logic for handling the add button press.
                        },
                        icon: const Icon(Icons.add, color: Colors.black,),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
            ),
          ],
        ),
      ),
            const SizedBox(
              height: 10,
            ),
          
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Parts",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Labour",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

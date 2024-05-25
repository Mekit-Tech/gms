import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mekit_gms/UI/screens/pdf_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mekit_gms/UI/screens/addparts.dart';
import 'package:mekit_gms/UI/screens/addlabour.dart';

// ignore: must_be_immutable
class VehicleProfile extends StatefulWidget {
  VehicleProfile(this.doc, {Key? key}) : super(key: key);
  QueryDocumentSnapshot doc;
  @override
  State<VehicleProfile> createState() => _VehicleProfileState();
}

final TextEditingController partNameController = TextEditingController();
final TextEditingController amountController = TextEditingController();
final TextEditingController labourNameController = TextEditingController();
final TextEditingController labourCostController = TextEditingController();

int _currentQuantity = 1; // State variable for parts quantity

onPressedParts(BuildContext context) async {
  final newPart = await _showAddPartsPopup(context);
  if (newPart != null) {
    // Validate part information (optional)
    if (newPart.partName.isEmpty || newPart.quantity == 0) {
      // Show error message (e.g., "Please enter part name and quantity")
      return;
    }
    // Process the new part information here (e.g., add to a list)
    print("Added part: ${newPart.partName}, quantity: ${newPart.quantity}");
  }
}

onPressedLabour(BuildContext context) async {
  final newLabour = await _showAddLabourPopup(context);
  if (newLabour != null) {
    // Validate labour information (optional)
    if (newLabour.name.isEmpty || newLabour.cost == 0.0) {
      // Show error message (e.g., "Please enter labour name and cost")
      return;
    }
    // Process the new labour information here (e.g., add to a list)
    print("Added labour: ${newLabour.name}, cost: ${newLabour.cost}");
  }
}

Future<Labour?> _showAddLabourPopup(BuildContext context) async {
  return await showDialog<Labour>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add Labour'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labourNameController,
              decoration:
                  const InputDecoration(labelText: 'Labour Name/Description'),
            ),
            TextField(
              controller: labourCostController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cost'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final labourName = labourNameController.text;
              final String costText = labourCostController.text;
              // Validate cost (optional)
              if (double.tryParse(costText) == null) {
                // Show error message
                return;
              }
              final labourCost = double.parse(costText);
              Navigator.pop(
                  context,
                  Labour(
                    name: labourName,
                    cost: labourCost,
                  ));
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}

Future<AddParts?> _showAddPartsPopup(BuildContext context) async {
  final TextEditingController partNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  return await showDialog<AddParts>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add Parts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: partNameController,
              decoration: const InputDecoration(labelText: 'Part Name'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final partName = partNameController.text;
              final amount = double.tryParse(amountController.text) ?? 0.0;
              final quantity = int.tryParse(quantityController.text) ?? 0;
              Navigator.pop(
                  context,
                  AddParts(
                    partName: partName,
                    amount: amount,
                    quantity: quantity,
                  ));
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
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
                padding: const EdgeInsets.only(top: 5.0, right: 20),
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
                      const SizedBox(height: 2),
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
                        "Parts",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        onPressed: () =>
                            onPressedParts(context), // Pass context
                        icon: const Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
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
                        "Labour",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        onPressed: () => onPressedLabour(context),
                        icon: const Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Rs. 0",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
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

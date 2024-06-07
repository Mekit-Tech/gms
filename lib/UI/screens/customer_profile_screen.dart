import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mekit_gms/UI/screens/pdf_generator.dart'; // Ensure you have this import
import 'package:mekit_gms/UI/screens/addparts.dart'; // Ensure you have this import
import 'package:mekit_gms/UI/screens/addlabour.dart'; // Ensure you have this import

class VehicleProfile extends StatefulWidget {
  VehicleProfile(this.doc, {Key? key}) : super(key: key);
  final QueryDocumentSnapshot doc;

  @override
  State<VehicleProfile> createState() => _VehicleProfileState();
}

class _VehicleProfileState extends State<VehicleProfile> {
  List<Map<String, dynamic>> parts = [];
  List<Map<String, dynamic>> labour = [];
  double totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    loadPartsAndLabour();
  }

  void loadPartsAndLabour() async {
    final partsSnapshot = await FirebaseFirestore.instance
        .collection('cars')
        .doc(widget.doc.id)
        .collection('parts')
        .get();
    final labourSnapshot = await FirebaseFirestore.instance
        .collection('cars')
        .doc(widget.doc.id)
        .collection('labour')
        .get();

    setState(() {
      parts = partsSnapshot.docs.map((doc) => doc.data()).toList();
      labour = labourSnapshot.docs.map((doc) => doc.data()).toList();
      calculateTotalCost();
    });
  }

  void calculateTotalCost() {
    double total = 0.0;
    for (var part in parts) {
      total += part['amount'] * part['quantity'];
    }
    for (var lab in labour) {
      total += lab['cost'];
    }
    setState(() {
      totalCost = total;
    });
  }

  Future<void> addPart(String partName, double amount, int quantity) async {
    final partData = {
      'partName': partName,
      'amount': amount,
      'quantity': quantity,
    };

    await FirebaseFirestore.instance
        .collection('cars')
        .doc(widget.doc.id)
        .collection('parts')
        .add(partData);

    setState(() {
      parts.add(partData);
      calculateTotalCost();
    });
  }

  Future<void> addLabour(String name, double cost) async {
    final labourData = {
      'name': name,
      'cost': cost,
    };

    await FirebaseFirestore.instance
        .collection('cars')
        .doc(widget.doc.id)
        .collection('labour')
        .add(labourData);

    setState(() {
      labour.add(labourData);
      calculateTotalCost();
    });
  }

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
                return const Icon(Icons.error_outline);
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                print("Connection state is waiting.");
                return const CircularProgressIndicator();
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
            var data = await generatePdf(
                widget.doc, // QueryDocumentSnapshot
                parts, // List<Map<String, dynamic>> parts
                labour, // List<Map<String, dynamic>> labour
                totalCost, // double totalCost
                "uid", // String uid - replace with actual UID if available
                "customerId", // String customerId - replace with actual Customer ID if available
                "jobId" // String jobId - replace with actual Job ID if available
                );
            Directory appDocDirectory =
                await getApplicationDocumentsDirectory();
            String dirPath = '${appDocDirectory.path}/pdfs/';
            await File('$dirPath/file1.pdf').create(recursive: true);
            String filePath = '$dirPath/file1.pdf';
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
                        widget.doc["car_number"],
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
                        onPressed: () async {
                          final newPart = await _showAddPartsPopup(context);
                          if (newPart != null) {
                            await addPart(newPart.partName, newPart.amount,
                                newPart.quantity);
                          }
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  ...parts
                      .map((part) => Text(
                          '${part['partName']} - ${part['quantity']} @ Rs.${part['amount']} each'))
                      .toList(),
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
                        onPressed: () async {
                          final newLabour = await _showAddLabourPopup(context);
                          if (newLabour != null) {
                            await addLabour(newLabour.name, newLabour.cost);
                          }
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  ...labour
                      .map((lab) => Text('${lab['name']} - Rs.${lab['cost']}'))
                      .toList(),
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
                        "Total",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Rs. $totalCost",
                        style: const TextStyle(
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
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
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
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<Labour?> _showAddLabourPopup(BuildContext context) async {
    final TextEditingController labourNameController = TextEditingController();
    final TextEditingController labourCostController = TextEditingController();

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
                if (double.tryParse(costText) == null) {
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
}

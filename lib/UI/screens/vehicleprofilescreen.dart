import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mekit_gms/UI/screens/pdf_generator.dart';
import 'package:mekit_gms/UI/screens/receipt_pdf.dart';

class VehicleProfile extends StatefulWidget {
  final QueryDocumentSnapshot customer;
  final String jobId; // Define the jobId parameter here

  const VehicleProfile({Key? key, required this.customer, required this.jobId})
      : super(key: key);

  @override
  State<VehicleProfile> createState() => _VehicleProfileState();
}

class _VehicleProfileState extends State<VehicleProfile> {
  String _uid = '';
  List<Map<String, dynamic>> parts = [];
  List<Map<String, dynamic>> labors = [];
  bool loading = true; // Flag to track loading state

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchPartData();
    _fetchLaborData();
    // Start a timer to stop loading after 4 seconds
    Timer(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.uid;
      });
    }
  }

  Future<void> _fetchPartData() async {
    print("Fetching part data...");
    final partSnapshot = await FirebaseFirestore.instance
        .collection('garages')
        .doc(_uid)
        .collection('customers')
        .doc(widget.customer.id)
        .collection('jobs')
        .doc(widget.jobId)
        .collection('parts')
        .get();

    setState(() {
      parts = partSnapshot.docs.map((doc) => doc.data()).toList();
    });

    print("Fetched ${parts.length} parts");
  }

  Future<void> _fetchLaborData() async {
    print("Fetching labor data...");
    final laborSnapshot = await FirebaseFirestore.instance
        .collection('garages')
        .doc(_uid)
        .collection('customers')
        .doc(widget.customer.id)
        .collection('jobs')
        .doc(widget.jobId)
        .collection('labors')
        .get();

    setState(() {
      labors = laborSnapshot.docs.map((doc) => doc.data()).toList();
    });

    print("Fetched ${labors.length} labors");
  }

  Future<void> addPart(String partName, double amount, int quantity) async {
    setState(() {
      parts.add({'partName': partName, 'amount': amount, 'quantity': quantity});
    });

    await FirebaseFirestore.instance
        .collection('garages')
        .doc(_uid)
        .collection('customers')
        .doc(widget.customer.id)
        .collection('jobs')
        .doc(widget.jobId)
        .collection('parts')
        .add({'partName': partName, 'amount': amount, 'quantity': quantity});
  }

  Future<void> addLabor(String laborName, double cost) async {
    setState(() {
      labors.add({'laborName': laborName, 'cost': cost});
    });

    await FirebaseFirestore.instance
        .collection('garages')
        .doc(_uid)
        .collection('customers')
        .doc(widget.customer.id)
        .collection('jobs')
        .doc(widget.jobId)
        .collection('labors')
        .add({'laborName': laborName, 'cost': cost});
  }

  double getTotalCost() {
    double partsTotal =
        parts.fold(0, (sum, part) => sum + part['amount'] * part['quantity']);
    double laborTotal = labors.fold(0, (sum, labor) => sum + labor['cost']);
    return partsTotal + laborTotal;
  }

  Future<void> generateAndSavePdf() async {
    var data = await generatePdf(widget.customer, parts, labors, getTotalCost(),
        _uid, widget.customer.id, widget.jobId);

    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String dirPath = '${appDocDirectory.path}/pdfs/';
    await File('$dirPath/file1.pdf').create(recursive: true);
    String filePath = '$dirPath/file1.pdf';
    print(filePath);
  }

  Future<Map<String, dynamic>?> _showAddPartPopup(BuildContext context) async {
    final TextEditingController partNameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Part'),
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
                Navigator.pop(context, {
                  'partName': partName,
                  'amount': amount,
                  'quantity': quantity
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _showAddLaborPopup(BuildContext context) async {
    final TextEditingController laborNameController = TextEditingController();
    final TextEditingController costController = TextEditingController();

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Labor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: laborNameController,
                decoration: const InputDecoration(labelText: 'Labor Name'),
              ),
              TextField(
                controller: costController,
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
                final laborName = laborNameController.text;
                final cost = double.tryParse(costController.text) ?? 0.0;
                Navigator.pop(context, {'laborName': laborName, 'cost': cost});
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              splashColor: Colors.greenAccent.shade700,
              hoverColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: generateAndSavePdf, // Function to generate estimate
              child: const Icon(
                Icons.arrow_right_outlined,
              ),
            ),
          ),
          // Positioned(
          //   bottom: 16,
          //   right: 16,
          //   child: FloatingActionButton(
          //     backgroundColor: Colors.black,
          //     foregroundColor: Colors.white,
          //     splashColor: Colors.greenAccent.shade700,
          //     hoverColor: Colors.grey,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     onPressed: (null), // Function to generate receipt
          //     child: const Icon(
          //       Icons.receipt,
          //     ),
          //   ),
          // ),
        ],
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
                        widget.customer["customer_name"],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.customer["car_number"],
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
            Expanded(
              child: ListView(
                children: [
                  buildPartSection(),
                  const SizedBox(height: 10),
                  buildLaborSection(),
                  const SizedBox(height: 10),
                  buildTotalSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPartSection() {
    return Container(
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
                  final newPart = await _showAddPartPopup(context);
                  if (newPart != null) {
                    addPart(newPart['partName'], newPart['amount'],
                        newPart['quantity']);
                  }
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          parts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No parts available",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: parts
                      .map((part) => ListTile(
                            title: Text(part['partName']),
                            subtitle: Text(
                                'Amount: ${part['amount']} x Quantity: ${part['quantity']}'),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget buildLaborSection() {
    return Container(
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
                "Labor",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () async {
                  final newLabor = await _showAddLaborPopup(context);
                  if (newLabor != null) {
                    addLabor(newLabor['laborName'], newLabor['cost']);
                  }
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          labors.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No labors available",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: labors
                      .map((labor) => ListTile(
                            title: Text(labor['laborName']),
                            subtitle: Text('Cost: ${labor['cost']}'),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total",
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            "Rs. ${getTotalCost()}",
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

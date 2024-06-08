import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mekit_gms/UI/screens/pdf_generator.dart';
import 'package:share_plus/share_plus.dart'; // Add this import

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
    if (partName.isEmpty || amount <= 0)
      return; // Check for empty part name or invalid amount

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
    if (laborName.isEmpty || cost <= 0)
      return; // Check for empty labor name or invalid cost

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
    try {
      // Generate PDF data
      var data = await generatePdf(widget.customer, parts, labors,
          getTotalCost(), _uid, widget.customer.id, widget.jobId);

      // Get application document directory
      Directory appDocDirectory = await getApplicationDocumentsDirectory();
      String dirPath = '${appDocDirectory.path}/pdfs/';
      await Directory(dirPath).create(recursive: true);

      // Define file path
      String filePath = '$dirPath/order.pdf';
      final file = File(filePath);

      // Write PDF data to file
      await file.writeAsBytes(data);

      print(filePath);

      // Share PDF file
      Share.shareFiles([filePath], text: 'Here is your PDF.');
    } catch (e) {
      print('Error generating and sharing PDF: $e');
      // Handle the error, e.g., show a snackbar or alert dialog to the user
    }
  }

  Future<Map<String, dynamic>?> _showAddPopup(BuildContext context) async {
    final TextEditingController partNameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController laborNameController = TextEditingController();
    final TextEditingController costController = TextEditingController();
    int quantity = 1;

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Part and Labor'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quantity'),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                  ),
                  Text(quantity.toString()),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ],
              ),
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
                final partName = partNameController.text;
                final amount = double.tryParse(amountController.text) ?? 0.0;
                final laborName = laborNameController.text;
                final cost = double.tryParse(costController.text) ?? 0.0;
                Navigator.pop(context, {
                  'partName': partName,
                  'amount': amount,
                  'quantity': quantity,
                  'laborName': laborName,
                  'cost': cost
                });
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
            buildTotalSection(),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  buildPartSection(),
                  const SizedBox(height: 10),
                  buildLaborSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final newEntry = await _showAddPopup(context);
                  if (newEntry != null) {
                    addPart(newEntry['partName'], newEntry['amount'],
                        newEntry['quantity']);
                    addLabor(newEntry['laborName'], newEntry['cost']);
                  }
                },
                child: Container(
                  color: Colors.blue,
                  height: 60,
                  child: const Center(
                    child: Text(
                      "Add Part & Labor",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: generateAndSavePdf,
                child: Container(
                  color: Colors.green,
                  height: 60,
                  child: const Center(
                    child: Text(
                      "Generate PDF",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Parts",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
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
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await deletePart(part);
                              },
                            ),
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Labor",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
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
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await deleteLabor(labor);
                              },
                            ),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Future<void> deletePart(Map<String, dynamic> part) async {
    final partRef = await FirebaseFirestore.instance
        .collection('garages')
        .doc(_uid)
        .collection('customers')
        .doc(widget.customer.id)
        .collection('jobs')
        .doc(widget.jobId)
        .collection('parts')
        .where('partName', isEqualTo: part['partName'])
        .where('amount', isEqualTo: part['amount'])
        .where('quantity', isEqualTo: part['quantity'])
        .get();

    for (var doc in partRef.docs) {
      await doc.reference.delete();
    }

    setState(() {
      parts.remove(part);
    });
  }

  Future<void> deleteLabor(Map<String, dynamic> labor) async {
    final laborRef = await FirebaseFirestore.instance
        .collection('garages')
        .doc(_uid)
        .collection('customers')
        .doc(widget.customer.id)
        .collection('jobs')
        .doc(widget.jobId)
        .collection('labors')
        .where('laborName', isEqualTo: labor['laborName'])
        .where('cost', isEqualTo: labor['cost'])
        .get();

    for (var doc in laborRef.docs) {
      await doc.reference.delete();
    }

    setState(() {
      labors.remove(labor);
    });
  }
}

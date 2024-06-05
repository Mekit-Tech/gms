import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mekit_gms/UI/screens/pdf_generator.dart';

class VehicleProfile extends StatefulWidget {
  final QueryDocumentSnapshot customer;
  final String jobId;

  const VehicleProfile({Key? key, required this.customer, required this.jobId})
      : super(key: key);

  @override
  State<VehicleProfile> createState() => _VehicleProfileState();
}

class _VehicleProfileState extends State<VehicleProfile> {
  String _uid = '';
  List<Map<String, dynamic>> parts = [];
  List<Map<String, dynamic>> labors = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchJobDetails();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.uid;
      });
    }
  }

  Future<void> _fetchJobDetails() async {
    if (_uid.isNotEmpty) {
      final partsSnapshot = await FirebaseFirestore.instance
          .collection('garages')
          .doc(_uid)
          .collection('customers')
          .doc(widget.customer.id)
          .collection('jobs')
          .doc(widget.jobId)
          .collection('parts')
          .get();

      final laborsSnapshot = await FirebaseFirestore.instance
          .collection('garages')
          .doc(_uid)
          .collection('customers')
          .doc(widget.customer.id)
          .collection('jobs')
          .doc(widget.jobId)
          .collection('labors')
          .get();

      setState(() {
        parts = partsSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        labors = laborsSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> addOrUpdatePart(
      {String? partId,
      required String partName,
      required double amount,
      required int quantity}) async {
    if (partId == null) {
      // Add new part
      await FirebaseFirestore.instance
          .collection('garages')
          .doc(_uid)
          .collection('customers')
          .doc(widget.customer.id)
          .collection('jobs')
          .doc(widget.jobId)
          .collection('parts')
          .add({'partName': partName, 'amount': amount, 'quantity': quantity});
    } else {
      // Update existing part
      await FirebaseFirestore.instance
          .collection('garages')
          .doc(_uid)
          .collection('customers')
          .doc(widget.customer.id)
          .collection('jobs')
          .doc(widget.jobId)
          .collection('parts')
          .doc(partId)
          .update(
              {'partName': partName, 'amount': amount, 'quantity': quantity});
    }

    _fetchJobDetails();
  }

  Future<void> addOrUpdateLabor(
      {String? laborId,
      required String laborName,
      required double cost}) async {
    if (laborId == null) {
      // Add new labor
      await FirebaseFirestore.instance
          .collection('garages')
          .doc(_uid)
          .collection('customers')
          .doc(widget.customer.id)
          .collection('jobs')
          .doc(widget.jobId)
          .collection('labors')
          .add({'laborName': laborName, 'cost': cost});
    } else {
      // Update existing labor
      await FirebaseFirestore.instance
          .collection('garages')
          .doc(_uid)
          .collection('customers')
          .doc(widget.customer.id)
          .collection('jobs')
          .doc(widget.jobId)
          .collection('labors')
          .doc(laborId)
          .update({'laborName': laborName, 'cost': cost});
    }

    _fetchJobDetails();
  }

  double getTotalCost() {
    double partsTotal =
        parts.fold(0, (sum, part) => sum + part['amount'] * part['quantity']);
    double laborTotal = labors.fold(0, (sum, labor) => sum + labor['cost']);
    return partsTotal + laborTotal;
  }

  Future<void> generateAndSavePdf() async {
    var data =
        await generatePdf(widget.customer, parts, labors, getTotalCost());
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String dirPath = '${appDocDirectory.path}/pdfs/';
    await File('$dirPath/file1.pdf').create(recursive: true);
    String filePath = '$dirPath/file1.pdf';
    print(filePath);
  }

  Future<Map<String, dynamic>?> _showPartDialog(
      {String? partId, String? partName, double? amount, int? quantity}) async {
    final TextEditingController partNameController =
        TextEditingController(text: partName);
    final TextEditingController amountController =
        TextEditingController(text: amount?.toString());
    final TextEditingController quantityController =
        TextEditingController(text: quantity?.toString());

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(partId == null ? 'Add Part' : 'Edit Part'),
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
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _showLaborDialog(
      {String? laborId, String? laborName, double? cost}) async {
    final TextEditingController laborNameController =
        TextEditingController(text: laborName);
    final TextEditingController costController =
        TextEditingController(text: cost?.toString());

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(laborId == null ? 'Add Labor' : 'Edit Labor'),
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
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> markJobAsCompleted() async {
    await FirebaseFirestore.instance
        .collection('garages')
        .doc(_uid)
        .collection('customers')
        .doc(widget.customer.id)
        .collection('jobs')
        .doc(widget.jobId)
        .update({'active': false});

    Navigator.pop(
        context); // Go back to the previous screen after marking as completed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Vehicle Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: markJobAsCompleted,
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customer['customer_name'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 25,
                  ),
                ),
                Text(
                  widget.customer['car_number'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.customer['car_model'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                Text(
                  widget.customer['year'].toString(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text("Parts"),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await _showPartDialog();
                if (result != null) {
                  await addOrUpdatePart(
                    partName: result['partName'],
                    amount: result['amount'],
                    quantity: result['quantity'],
                  );
                }
              },
            ),
          ),
          ...parts.map((part) {
            return ListTile(
              title: Text(part['partName']),
              subtitle: Text(
                  'Amount: ${part['amount']} x Quantity: ${part['quantity']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Total: ${(part['amount'] * part['quantity']).toStringAsFixed(2)}'),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await _showPartDialog(
                        partId: part['id'],
                        partName: part['partName'],
                        amount: part['amount'],
                        quantity: part['quantity'],
                      );
                      if (result != null) {
                        await addOrUpdatePart(
                          partId: part['id'],
                          partName: result['partName'],
                          amount: result['amount'],
                          quantity: result['quantity'],
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          }).toList(),
          ListTile(
            title: const Text("Labors"),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await _showLaborDialog();
                if (result != null) {
                  await addOrUpdateLabor(
                    laborName: result['laborName'],
                    cost: result['cost'],
                  );
                }
              },
            ),
          ),
          ...labors.map((labor) {
            return ListTile(
              title: Text(labor['laborName']),
              subtitle: Text('Cost: ${labor['cost']}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await _showLaborDialog(
                    laborId: labor['id'],
                    laborName: labor['laborName'],
                    cost: labor['cost'],
                  );
                  if (result != null) {
                    await addOrUpdateLabor(
                      laborId: labor['id'],
                      laborName: result['laborName'],
                      cost: result['cost'],
                    );
                  }
                },
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          ListTile(
            title: const Text("Total Cost"),
            trailing: Text(getTotalCost().toStringAsFixed(2)),
          ),
        ],
      ),
    );
  }
}

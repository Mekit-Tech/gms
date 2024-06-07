import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mekit_gms/UI/screens/pdf_generator.dart';
import 'package:mekit_gms/utils/commonspareparts.dart';

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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchPartData();
    _fetchLaborData();
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
      parts = partSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
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
      labors = laborSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    });

    print("Fetched ${labors.length} labors");
  }

  Future<void> addPart(String partName, double amount, int quantity) async {
    if (partName.isEmpty || amount <= 0 || quantity <= 0) return;

    final part = {'partName': partName, 'amount': amount, 'quantity': quantity};

    final partRef = await FirebaseFirestore.instance
        .collection('garages')
        .doc(_uid)
        .collection('customers')
        .doc(widget.customer.id)
        .collection('jobs')
        .doc(widget.jobId)
        .collection('parts')
        .add(part);

    setState(() {
      parts.add({'id': partRef.id, ...part});
    });
  }

  Future<void> addLabor(String laborName, double cost) async {
    if (laborName.isEmpty || cost <= 0) return;

    final labor = {'laborName': laborName, 'cost': cost};

    final laborRef = await FirebaseFirestore.instance
        .collection('garages')
        .doc(_uid)
        .collection('customers')
        .doc(widget.customer.id)
        .collection('jobs')
        .doc(widget.jobId)
        .collection('labors')
        .add(labor);

    setState(() {
      labors.add({'id': laborRef.id, ...labor});
    });
  }

  Future<void> deletePart(int index) async {
    final partId = parts[index]['id'];
    setState(() {
      parts.removeAt(index);
    });

    await FirebaseFirestore.instance
        .collection('garages')
        .doc(_uid)
        .collection('customers')
        .doc(widget.customer.id)
        .collection('jobs')
        .doc(widget.jobId)
        .collection('parts')
        .doc(partId)
        .delete();
  }

  Future<void> deleteLabor(int index) async {
    final laborId = labors[index]['id'];
    setState(() {
      labors.removeAt(index);
    });

    await FirebaseFirestore.instance
        .collection('garages')
        .doc(_uid)
        .collection('customers')
        .doc(widget.customer.id)
        .collection('jobs')
        .doc(widget.jobId)
        .collection('labors')
        .doc(laborId)
        .delete();
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

  Future<Map<String, dynamic>?> _showAddPopup(BuildContext context) async {
    final TextEditingController partNameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController laborNameController = TextEditingController();
    final TextEditingController costController = TextEditingController();
    int quantity = 1;

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Part and Labor'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TypeAheadField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: partNameController,
                      decoration: const InputDecoration(labelText: 'Part Name'),
                    ),
                    suggestionsCallback: (pattern) {
                      return commonSpareParts.where((part) =>
                          part.toLowerCase().contains(pattern.toLowerCase()));
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      partNameController.text = suggestion;
                    },
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
                    final amount =
                        double.tryParse(amountController.text) ?? 0.0;
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
              height: 105,
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
                    if (newEntry['partName'].isNotEmpty &&
                        newEntry['amount'] > 0 &&
                        newEntry['quantity'] > 0) {
                      await addPart(newEntry['partName'], newEntry['amount'],
                          newEntry['quantity']);
                    }
                    if (newEntry['laborName'].isNotEmpty &&
                        newEntry['cost'] > 0) {
                      await addLabor(newEntry['laborName'], newEntry['cost']);
                    }
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
                      .asMap()
                      .entries
                      .map((entry) => ListTile(
                            title: Text(entry.value['partName']),
                            subtitle: Text(
                                'Amount: ${entry.value['amount']} x Quantity: ${entry.value['quantity']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deletePart(entry.key),
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
                      .asMap()
                      .entries
                      .map((entry) => ListTile(
                            title: Text(entry.value['laborName']),
                            subtitle: Text('Cost: ${entry.value['cost']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteLabor(entry.key),
                            ),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }
}

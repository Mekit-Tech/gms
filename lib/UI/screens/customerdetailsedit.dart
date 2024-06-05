import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCustomerDetails extends StatefulWidget {
  final String garageId;
  final String customerId;

  const EditCustomerDetails({
    Key? key,
    required this.garageId,
    required this.customerId,
  }) : super(key: key);

  @override
  _EditCustomerDetailsState createState() => _EditCustomerDetailsState();
}

class _EditCustomerDetailsState extends State<EditCustomerDetails> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController chassisNumberController = TextEditingController();
  TextEditingController regNoController = TextEditingController();
  TextEditingController carModelController = TextEditingController();
  TextEditingController customerAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomerDetails();
  }

  Future<void> _fetchCustomerDetails() async {
    DocumentSnapshot customerDoc = await FirebaseFirestore.instance
        .collection('garages')
        .doc(widget.garageId)
        .collection('customers')
        .doc(widget.customerId)
        .get();

    var customerData = customerDoc.data() as Map<String, dynamic>;

    setState(() {
      nameController.text = customerData['customer_name'] ?? '';
      phoneNumberController.text = customerData['customer_phone'] ?? '';
      chassisNumberController.text = customerData['chassis_number'] ?? '';
      regNoController.text = customerData['car_number'] ?? '';
      carModelController.text = customerData['car_model'] ?? '';
      customerAddressController.text = customerData['customer_address'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Customer Details'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: regNoController,
                decoration: const InputDecoration(
                    labelText: 'Vehicle Registration No.'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a vehicle number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: carModelController,
                decoration:
                    const InputDecoration(labelText: 'Car Make / Model'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a car model';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: chassisNumberController,
                decoration: const InputDecoration(labelText: 'Chassis Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a chassis number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: customerAddressController,
                decoration:
                    const InputDecoration(labelText: 'Customer Address'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await FirebaseFirestore.instance
                        .collection('garages')
                        .doc(widget.garageId)
                        .collection('customers')
                        .doc(widget.customerId)
                        .update({
                      'customer_name': nameController.text,
                      'customer_phone': phoneNumberController.text,
                      'chassis_number': chassisNumberController.text,
                      'car_number': regNoController.text,
                      'car_model': carModelController.text,
                      'customer_address': customerAddressController.text,
                    });

                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

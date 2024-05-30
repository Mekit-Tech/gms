import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNew extends StatefulWidget {
  const AddNew({Key? key}) : super(key: key);

  @override
  State<AddNew> createState() => _AddNewState();
}

class _AddNewState extends State<AddNew> {
  // Define controllers for text fields
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController chassisNumberController = TextEditingController();
  TextEditingController regNoController = TextEditingController();
  TextEditingController carModelController = TextEditingController();

  // Form key for validation and saving
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TextStyle
  final TextStyle _myStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color.fromARGB(255, 48, 217, 163),
        elevation: 0.0,
        title: const Text(
          "Add Customer",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                // Add customer data to Firestore
                await FirebaseFirestore.instance.collection("customers").add({
                  "car_number": regNoController.text,
                  "customer_name": nameController.text,
                  "phone_number": phoneNumberController.text,
                  "chassis_number": chassisNumberController.text,
                  "car_model": carModelController.text,
                }).then((value) {
                  // Navigate back after adding successfully
                  Navigator.pop(context);
                }).catchError((error) {
                  // Handle error if adding failed
                  print("Failed to Add New Customer due to $error");
                });
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Customer Name",
                  style: _myStyle,
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: nameController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please Enter Name";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Customer Name",
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Vehicle Registration No.",
                  style: _myStyle,
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: regNoController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Enter Vehicle Number";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "MH 01 AB 0007",
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Car Make / Model",
                  style: _myStyle,
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: carModelController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Enter Vehicle Brand and Model";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Honda City",
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Phone Number",
                  style: _myStyle,
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Enter Phone Number";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "88886 57702",
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Chassis Number",
                  style: _myStyle,
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: chassisNumberController,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Enter Chassis Number";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "1234567891234567",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddNew extends StatefulWidget {
  const AddNew({Key? key}) : super(key: key);

  @override
  State<AddNew> createState() => _AddNewState();
}

class _AddNewState extends State<AddNew> {
  GlobalKey<FormState> contactkey = GlobalKey<FormState>();

  TextEditingController namecontroller = TextEditingController();
  TextEditingController phonenumbercontroller = TextEditingController();
  TextEditingController chassisnumbercontroller = TextEditingController();
  TextEditingController regnocontroller = TextEditingController();
  TextEditingController carmodelcontroller = TextEditingController();

  String? name;
  String? phone;
  String? regno;
  String? chassisnumber;
  String? carmodel;

  TextStyle mystyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Color.fromARGB(255, 48, 217, 163),
        elevation: 0.0,
        title: const Text(
          "Add Customer",
          selectionColor: Colors.white,
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
                if (contactkey.currentState!.validate()) {
                  contactkey.currentState!.save();

                  FirebaseFirestore.instance.collection("cars").add({
                    "rto_number": regnocontroller.text,
                    "customer_name": namecontroller.text,
                    "phone_no": phonenumbercontroller.text,
                    "chassis_number": chassisnumbercontroller.text,
                    "car_model": carmodelcontroller.text,
                  }).then((value) {
                    Navigator.pop(context);
                  }).catchError((error) =>
                      // ignore: avoid_print, invalid_return_type_for_catch_error
                      print("Failed to Add New Customer due to $error"));
                }
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: contactkey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Customer Name",
                          style: mystyle,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: namecontroller,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Please Enter Name";
                            }
                            return null;
                          },
                          onSaved: (val) {
                            setState(() {
                              name = val;
                            });
                          },
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              hintText: "Customer Name"),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Vehicle Registration No.",
                          style: mystyle,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: regnocontroller,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Enter Vehicle Number";
                            }
                            return null;
                          },
                          onSaved: (val) {
                            setState(() {
                              regno = val;
                            });
                          },
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              hintText: "MH 01 AB 0007"),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Car Model",
                          style: mystyle,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: carmodelcontroller,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Enter Vehicle Brand and Model";
                            }
                            return null;
                          },
                          onSaved: (val) {
                            setState(() {
                              carmodel = val;
                            });
                          },
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              hintText: "Honda City"),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Phone Number",
                          style: mystyle,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: phonenumbercontroller,
                          keyboardType: TextInputType.phone,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Enter Phone Number";
                            }
                            return null;
                          },
                          onSaved: (val) {
                            setState(() {
                              phone = val;
                            });
                          },
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              hintText: "88886 57702"),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Chassis Number",
                          style: mystyle,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: chassisnumbercontroller,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Enter Chassis Number";
                            }
                            return null;
                          },
                          onSaved: (val) {
                            setState(() {
                              chassisnumber = val;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                              ),
                            ),
                            hintText: "1234567891234567",
                          ),
                        ),
                      ],
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
}

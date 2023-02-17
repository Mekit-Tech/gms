
import 'package:flutter/material.dart';
import 'package:mekit_gms/models/customer.dart';

class AddNew extends StatefulWidget {
  const AddNew({Key? key}) : super(key: key);

  @override
  State<AddNew> createState() => _AddNewState();
}

class _AddNewState extends State<AddNew> {
  GlobalKey<FormState> contactkey = GlobalKey<FormState>();

  TextEditingController namecontroller = TextEditingController();
  TextEditingController phonenumbercontroller = TextEditingController();
  TextEditingController odoreadingcontroller = TextEditingController();
  TextEditingController regnocontroller = TextEditingController();

  String? name;
  String? phone;
  String? regno;
  String? odoreading;

  TextStyle mystyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.black,
        elevation: 0.0,
        title: const Text("Add Customer"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                if (contactkey.currentState!.validate()) {
                  contactkey.currentState!.save();

                  CustomerModel c1 = CustomerModel(
                    name: name,
                    phone: phone,
                    regno: regno,
                    odoreading: odoreading,
                  );

                  // setState(() {
                  //   Global.allcontacts.add(c1);
                  // });

                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('homepage', (route) => false);
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
                          "KMs Reading",
                          style: mystyle,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: odoreadingcontroller,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Enter Odometer Reading";
                            }
                            return null;
                          },
                          onSaved: (val) {
                            setState(() {
                              odoreading = val;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                              ),
                            ),
                            hintText: "25,000 KMs",
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

import 'package:flutter/material.dart';
import '../../../utils/allcaps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddJobs extends StatefulWidget {
  const AddJobs({Key? key}) : super(key: key);

  @override
  State<AddJobs> createState() => _AddJobsState();
}

class _AddJobsState extends State<AddJobs> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: <Widget>[
          Container(
            margin:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
            width: 350,
            constraints: const BoxConstraints(
              maxHeight: double.infinity,
            ),
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFFE2E2E2),
                  Color(0xFFF0EFEF),
                ],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      "Reg. No.",
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextFormField(
                          style: const TextStyle(fontFamily: 'DMSans'),
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                          ],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 17),
                            filled: true,
                            fillColor: Colors.white,
                            focusColor: Colors.white,
                            hintText: 'MH 01 AB 0007',
                          ),
                          // onSaved: (value) => regno = value!,
                        ),
                      ),
                    )
                  ],
                ),

                // Registration Input

                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        "Phone",
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, top: 30),
                        child: TextFormField(
                          style: const TextStyle(fontFamily: 'DMSans'),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 17),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '8888657702',
                          ),
                          // onSaved: (value) => phone = value as int,
                        ),
                      ),
                    )
                  ],
                ),

                // Phone Input

                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Divider(
                    color: Colors.black,
                  ),
                ),

                // Add Job Button Below

                InkWell(
                  onTap: () {},
                  child: Container(
                    width: double.maxFinite,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Colors.white,
                    ),
                    margin: const EdgeInsets.only(top: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/icons/add-icon.png'),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              "Add Job",
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bill Button

                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.maxFinite,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(40),
                      ),
                      color: const Color(0xFF336699),
                    ),
                    margin: const EdgeInsets.only(top: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              "Bill",
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactsWidget extends StatelessWidget {
  final String garageId;

  const ContactsWidget({Key? key, required this.garageId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.7)),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('customers')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var customers = snapshot.data!.docs;

          return Column(
            children: customers.map((customer) {
              var customerData = customer.data() as Map<String, dynamic>;
              return Column(
                children: [
                  Row(
                    children: [
                      Text(
                        customerData['customer_name'] ?? '',
                        style: const TextStyle(
                          fontFamily: 'DMSans - Regular',
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          customerData['car_model'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'DMSans - Regular',
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, height: 20),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

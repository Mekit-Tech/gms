import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mekit_gms/UI/screens/customerdetails.dart'; // Import EditCustomerDetails screen

class CustomerContacts extends StatefulWidget {
  const CustomerContacts({Key? key}) : super(key: key);

  @override
  _CustomerContactsState createState() => _CustomerContactsState();
}

class _CustomerContactsState extends State<CustomerContacts> {
  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        User? user = snapshot.data;
        String garageId = user!.uid;

        return StreamBuilder<QuerySnapshot>(
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

            return ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                var customer = customers[index];
                var customerData = customer.data() as Map<String, dynamic>;

                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerDetails(
                            garageId: garageId,
                            customerId: customer.id,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerData['customer_name'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            customerData['car_number'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

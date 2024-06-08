import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mekit_gms/UI/screens/customerdetails.dart'; // Import EditCustomerDetails screen
import 'package:url_launcher/url_launcher.dart';

class CustomerContacts extends StatefulWidget {
  const CustomerContacts({Key? key}) : super(key: key);

  @override
  _CustomerContactsState createState() => _CustomerContactsState();
}

class _CustomerContactsState extends State<CustomerContacts> {
  String _searchQuery = '';
  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  void _makePhoneCall(String phoneNumber) async {
    final sanitizedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri url = Uri(scheme: 'tel', path: sanitizedPhoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Could not launch $url');
    }
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

        return Scaffold(
          appBar: AppBar(
            title: TextField(
              decoration: const InputDecoration(
                hintText: 'Search customers...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
            ),
            backgroundColor: Colors.blue,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('garages')
                .doc(garageId)
                .collection('customers')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var customers = snapshot.data!.docs.where((doc) {
                var customerData = doc.data() as Map<String, dynamic>;
                var customerName = customerData['customer_name'] ?? '';
                return customerName
                    .toString()
                    .toLowerCase()
                    .contains(_searchQuery);
              }).toList();

              return ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  var customer = customers[index];
                  var customerData = customer.data() as Map<String, dynamic>;

                  return Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: ListTile(
                      title: Text(
                        customerData['customer_name'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        customerData['car_number'] ?? 'Unknown Car Number',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () {
                          _makePhoneCall(customerData['phone_number']);
                        },
                      ),
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
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

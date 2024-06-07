import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mekit_gms/UI/screens/vehicleprofilescreen.dart';
import 'package:url_launcher/url_launcher.dart';

class AddJobs extends StatefulWidget {
  const AddJobs({Key? key}) : super(key: key);

  @override
  State<AddJobs> createState() => _AddJobsState();
}

class _AddJobsState extends State<AddJobs> {
  String _uid = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.uid;
      });
    }
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

  void _openWhatsApp(String phoneNumber) async {
    final sanitizedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri url = Uri.parse('https://wa.me/$sanitizedPhoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _uid.isNotEmpty
            ? FirebaseFirestore.instance
                .collection('garages')
                .doc(_uid)
                .collection('customers')
                .snapshots()
            : null,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: ListView(
                children: snapshot.data!.docs.map((customer) {
                  var customerData = customer.data() as Map<String, dynamic>?;

                  if (customerData == null) {
                    return const SizedBox.shrink();
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('garages')
                        .doc(_uid)
                        .collection('customers')
                        .doc(customer.id)
                        .collection('jobs')
                        .where('status', isEqualTo: 'active')
                        .snapshots(),
                    builder: (context, jobSnapshot) {
                      if (jobSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (jobSnapshot.hasData &&
                          jobSnapshot.data!.docs.isNotEmpty) {
                        return Column(
                          children: jobSnapshot.data!.docs.map((job) {
                            var jobData = job.data() as Map<String, dynamic>;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VehicleProfile(
                                      customer: customer,
                                      jobId: job.id,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                width: double.infinity,
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color:
                                      const Color.fromARGB(255, 210, 239, 253),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customerData['customer_name'] ??
                                                  'Unknown',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              jobData['car_number'] ?? 'N/A',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        if (customerData
                                            .containsKey('customer_phone')) ...[
                                          IconButton(
                                            icon: const Icon(Icons.call),
                                            color: Colors.green,
                                            onPressed: () {
                                              _makePhoneCall(
                                                  customerData['phone_number']);
                                            },
                                          ),
                                        ],
                                        if (customerData
                                            .containsKey('customer_phone')) ...[
                                          IconButton(
                                            icon: const Icon(Icons.message),
                                            color: Colors.green,
                                            onPressed: () {
                                              _openWhatsApp(
                                                  customerData['phone_number']);
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return const Center(
                          child: Text(""),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            );
          } else {
            return const Center(
              child: Text(
                "You have no customers",
              ),
            );
          }
        },
      ),
    );
  }
}

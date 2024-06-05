import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mekit_gms/UI/screens/vehicleprofilescreen.dart'; // Import VehicleProfile screen

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
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('garages')
                        .doc(_uid)
                        .collection('customers')
                        .doc(customer.id)
                        .collection('jobs')
                        .where('active', isEqualTo: true)
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
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(customer['customer_name']),
                                    Text(customer['car_number']),
                                    Text(job.id),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return const Center(
                          child: Text("No active jobs for this customer"),
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

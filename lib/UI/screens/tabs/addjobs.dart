import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mekit_gms/UI/screens/vehicleprofilescreen.dart';

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
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  width: double.infinity,
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    color: Color.fromARGB(255, 210, 239,
                                        253), // Set light blue background color
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customer['customer_name'],
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            jobData['primary_job'] ?? 'N/A',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ));
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

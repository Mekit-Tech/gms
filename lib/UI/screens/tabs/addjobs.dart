import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/card_widget.dart'; // Import your noteCard widget here
import '../customer_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddJobs extends StatefulWidget {
  const AddJobs({Key? key}) : super(key: key);

  @override
  State<AddJobs> createState() => _AddJobsState();
}

class _AddJobsState extends State<AddJobs> {
  String _uid = ''; // Initialize _uid with an empty string

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Call this method when the widget initializes
  }

  // Method to get the current user's UID
  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.uid; // Store the UID in the variable
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
            : null, // Pass null if _uid is empty to prevent Firestore query
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //checking the connection state, if we still load the data we display a progress bar
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                children: snapshot.data!.docs
                    .map((car) => noteCard(
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VehicleProfile(car),
                              ),
                            );
                          },
                          car,
                        ))
                    .toList(),
              ),
            );
          } else {
            return const Center(
              child: Text(
                "You have no cars",
              ),
            );
          }
        },
      ),
    );
  }
}

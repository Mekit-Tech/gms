import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/card_widget.dart';
import '../customer_profile_screen.dart';

class AddJobs extends StatefulWidget {
  const AddJobs({Key? key}) : super(key: key);

  @override
  State<AddJobs> createState() => _AddJobsState();
}

class _AddJobsState extends State<AddJobs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("cars").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //checking the connection state, if we still load the data we display a progress bar
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                children: snapshot.data!.docs
                    .map((cars) => noteCard(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleProfile(cars),
                            ),
                          );
                        }, cars))
                    .toList(),
              ),
            );
          }
          return const Text(
            "You have no cars",
          );
        },
      ),
    );
  }
}

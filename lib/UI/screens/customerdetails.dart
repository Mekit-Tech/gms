import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customerdetailsedit.dart';
import 'customerinteraction.dart'; // Import the new screen to create interaction

class CustomerDetails extends StatelessWidget {
  final String garageId;
  final String customerId;

  const CustomerDetails({
    Key? key,
    required this.garageId,
    required this.customerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCustomerDetails(
                    garageId: garageId,
                    customerId: customerId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('customers')
            .doc(customerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var customer = snapshot.data!;
          var customerData = customer.data() as Map<String, dynamic>;

          // Provide default values for null fields
          String customerName = customerData['customer_name'] ?? 'N/A';
          String carNumber = customerData['car_number'] ?? 'N/A';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to a more detailed customer view if needed
                },
                child: Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      customerName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      carNumber,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Interactions', style: TextStyle(fontSize: 18)),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('garages')
                      .doc(garageId)
                      .collection('customers')
                      .doc(customerId)
                      .collection('jobs') // Updated to fetch from 'jobs'
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var jobs = snapshot.data!.docs;

                    if (jobs.isEmpty) {
                      return const Center(
                        child: Text('No interactions found.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        var job = jobs[index];
                        var jobData = job.data() as Map<String, dynamic>;

                        String description = jobData['primary_job'] ?? 'N/A';
                        String date = jobData['date_time'] != null
                            ? formatDate(DateTime.parse(jobData['date_time']))
                            : 'N/A';
                        String status = jobData['status'] ?? 'active';

                        return Card(
                          elevation: 2.0,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: ListTile(
                            title: Text(description),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: $date'),
                                Text('Status: $status'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                status == 'active'
                                    ? Icons.check_box_outline_blank
                                    : Icons.check_box,
                              ),
                              onPressed: () {
                                updateJobStatus(garageId, customerId, job.id,
                                    status == 'active' ? 'done' : 'active');
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateInteractionScreen(
                garageId: garageId,
                customerId: customerId,
              ),
            ),
          );
        },
        label: const Text('Create Interaction'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][date.month - 1]} '
        '${date.year}';
  }

  void updateJobStatus(
      String garageId, String customerId, String jobId, String newStatus) {
    FirebaseFirestore.instance
        .collection('garages')
        .doc(garageId)
        .collection('customers')
        .doc(customerId)
        .collection('jobs')
        .doc(jobId)
        .update({'status': newStatus});
  }
}

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
                      .collection('interactions')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var interactions = snapshot.data!.docs;

                    if (interactions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('No interactions found.'),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CreateInteractionScreen(
                                      garageId: garageId,
                                      customerId: customerId,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Create Interaction'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: interactions.length,
                      itemBuilder: (context, index) {
                        var interaction = interactions[index];
                        var interactionData =
                            interaction.data() as Map<String, dynamic>;

                        var labor =
                            interactionData['labor'] as List<dynamic>? ?? [];
                        var parts =
                            interactionData['parts'] as List<dynamic>? ?? [];

                        return Card(
                          elevation: 2.0,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: ExpansionTile(
                            title:
                                Text(interactionData['description'] ?? 'N/A'),
                            subtitle: Text(
                                'Date: ${interactionData['date'] ?? 'N/A'}'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Labor:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    ...labor.map((item) => Text(item)).toList(),
                                    SizedBox(height: 8.0),
                                    Text('Parts:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    ...parts.map((item) => Text(item)).toList(),
                                  ],
                                ),
                              ),
                            ],
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
    );
  }
}

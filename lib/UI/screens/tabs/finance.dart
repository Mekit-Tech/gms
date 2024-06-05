import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({Key? key}) : super(key: key);

  @override
  _MoneyScreenState createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    // Initialize the transactions list with existing data
    _fetchTransactions();
  }

  // Fetch transactions from Firestore
  Future<void> _fetchTransactions() async {
    try {
      // Example: Fetch transactions from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(
              'transactions') // Replace with your Firestore collection name
          .get();

      setState(() {
        transactions = querySnapshot.docs
            .map((doc) => Transaction.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bills Sent (₹${_calculateTotalAmount()})",
              style: const TextStyle(
                fontFamily: 'DMSans',
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (BuildContext context, int index) {
                return TransactionItem(transaction: transactions[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Calculate total amount of transactions
  double _calculateTotalAmount() {
    double totalAmount = 0;
    for (var transaction in transactions) {
      totalAmount += transaction.amount;
    }
    return totalAmount;
  }
}

class Transaction {
  final String title;
  final double amount;

  Transaction({required this.title, required this.amount});

  // Create a Transaction object from a Firestore document
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Transaction(
      title: data['title'] ?? '',
      amount: data['amount'] ?? 0,
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '₹${transaction.amount.toString()}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

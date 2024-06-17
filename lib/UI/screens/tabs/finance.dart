import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MoneyScreen(),
    );
  }
}

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({Key? key}) : super(key: key);

  @override
  _MoneyScreenState createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  List<Transaction> transactions = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      print('Fetching transactions...');
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('status', isEqualTo: 'pending')
          .get();

      setState(() {
        transactions = querySnapshot.docs
            .map((doc) => Transaction.fromFirestore(doc))
            .toList();
        isLoading = false;
      });

      print('Transactions fetched: ${transactions.length}');
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching transactions: $e';
        isLoading = false;
      });

      print('Error fetching transactions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: transactions.map((transaction) {
                      return Dismissible(
                        key: Key(transaction.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.green,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Icon(Icons.done, color: Colors.white),
                          ),
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            transactions.remove(transaction);
                            _markTransactionAsDone(transaction);
                          });
                        },
                        child: TransactionItem(transaction: transaction),
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  Future<void> _markTransactionAsDone(Transaction transaction) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transaction.id)
          .update({'status': 'done'});
      print('Transaction marked as done: ${transaction.title}');
    } catch (e) {
      print('Error marking transaction as done: $e');
    }
  }
}

class Transaction {
  final String id;
  final String title;
  final double amount;

  Transaction({required this.id, required this.title, required this.amount});

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (data == null) {
      throw Exception('Data is null');
    }
    return Transaction(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      amount: (data['amount'] ?? 0).toDouble(),
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

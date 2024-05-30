import 'package:flutter/material.dart';
import '../../../UI/widgets/demo_billssent.dart';
import '../../../UI/widgets/demo_clearedbills.dart';

class MoneyScreen extends StatelessWidget {
  const MoneyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Container(
          margin:
              const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
          width: double.infinity,
          constraints: const BoxConstraints(
            maxHeight: double.infinity,
          ),
          child: const Column(
            children: [
              Text(
                "Bills Sent (₹70,510)",
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.normal,
                ),
              ),
              BillsSent(),
              BillsSent(),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  "Cleared bills",
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              ClearedBills(),
              ClearedBills(),
            ],
          ),
        ),
      ]),
    );
  }
}

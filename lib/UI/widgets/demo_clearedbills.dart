import 'package:flutter/material.dart';

class ClearedBills extends StatelessWidget {
  const ClearedBills({Key? key}) : super(key: key);

  static const IconData whatsapp =
      IconData(0xf05a6, fontFamily: 'MaterialIcons');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 15, right: 10, bottom: 10),
      margin: const EdgeInsets.only(top: 20),
      height: 90,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF0EFEF),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Column(
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 5, left: 10, bottom: 5),
                child: Text(
                  "Anu Malik",
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "₹1,900",
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          Column(
            children: const [
              Padding(
                padding: EdgeInsets.only(left: 130, top: 5),
                child: Text(
                  "Bank",
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0XFF0FA958),
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 130, top: 5),
                child: Text(
                  "22 June 2022",
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

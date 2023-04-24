import 'package:flutter/material.dart';

class BillsSent extends StatelessWidget {
  const BillsSent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 15, right: 10, bottom: 10),
      margin: const EdgeInsets.only(top: 20),
      height: 100,
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
            children: [
              const Text(
                "₹1845",
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: Colors.black,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(
                      Icons.call,
                      color: Colors.blueAccent,
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 7, top: 7),
                    child: Text(
                      "Mota Bhai",
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 60),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0FA958),
            ),
            padding: const EdgeInsets.all(17),
            child: const Icon(
              Icons.check_outlined,
              color: Colors.white,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            padding: const EdgeInsets.all(15),
            child: Image.asset(
              'assets/icons/whatsapp.png',
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}

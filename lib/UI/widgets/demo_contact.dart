import 'package:flutter/material.dart';

class ContactsWidget extends StatelessWidget {
  const ContactsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.7)),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Text(
                "Adar Daruwala",
                style: TextStyle(
                  fontFamily: 'DMSans - Regular',
                  color: Colors.black,
                  fontSize: 18,
                ),
              )
            ],
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Honda City",
                  style: TextStyle(
                    fontFamily: 'DMSans - Regular',
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  ", Kia Seltos",
                  style: TextStyle(
                    fontFamily: 'DMSans - Regular',
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

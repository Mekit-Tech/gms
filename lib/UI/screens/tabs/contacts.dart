import 'package:flutter/material.dart';
import 'package:mekit_gms/UI/widgets/demo_contact.dart';

class CustomerContacts extends StatelessWidget {
  const CustomerContacts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      Container(
        margin: const EdgeInsets.only(left: 30, right: 30, top: 25, bottom: 40),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 15),
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: -9),
              BoxShadow(
                blurRadius: 7,
                offset: const Offset(0, 1),
                color: Colors.grey.withOpacity(0.6),
              )
            ]),
        child: const TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(20),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 20, right: 10),
              child: Icon(
                Icons.search,
                color: Colors.grey,
              ),
            ),
            hintText: 'Search by name or number',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ),
      const Text(
        "A - Z",
        style: TextStyle(
          fontFamily: 'DMSans - Regular',
          color: Colors.black,
          fontSize: 15,
        ),
      ),
      const ContactsWidget(),
      const ContactsWidget(),
      const ContactsWidget(),
      const ContactsWidget(),
      const ContactsWidget(),
      const ContactsWidget(),
      const ContactsWidget(),
      const ContactsWidget(),
    ]);
  }
}

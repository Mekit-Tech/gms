import 'package:flutter/material.dart';
import 'package:mekit_gms/UI/widgets/demo_contact.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerContacts extends StatefulWidget {
  const CustomerContacts({Key? key}) : super(key: key);

  @override
  _CustomerContactsState createState() => _CustomerContactsState();
}

class _CustomerContactsState extends State<CustomerContacts> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        User? user = snapshot.data;
        String garageId = user!.uid;

        return ContactsWidget(garageId: garageId);
      },
    );
  }

  Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }
}

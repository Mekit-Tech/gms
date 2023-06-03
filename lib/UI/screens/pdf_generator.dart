import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

generatePdf(QueryDocumentSnapshot doc) async {
  String firebaseInstance = "customer_name";
  print(doc.data());
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Center(
          child: pw.Text(doc.data().toString()),
        );
      },
    ),
  );
  return pdf.save();
}

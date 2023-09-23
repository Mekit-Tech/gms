import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart'; // Import the open_file package
import 'dart:io';

generatePdf(QueryDocumentSnapshot doc) async {
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

  // Generate the PDF and save it to a file
  final directory = await getTemporaryDirectory();
  final outputFile = File('${directory.path}/example.pdf');
  await outputFile.writeAsBytes(await pdf.save());

  // Open the PDF file using the open_file package
  if (await outputFile.exists()) {
    await OpenFile.open(outputFile.path);
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_document/open_document.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFGenerator {
  Future<Uint8List> createInvoice() {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("Invoice 001"),
          );
        },
      ),
    );

    return pdf.save();
    
  }
}

Future<void> savePDFFile(String fileName, Uint8List byteList) async {
  final output = await getTemporaryDirectory(); // Creates a temporary directory
  var filePath =
      "${output.path}/$fileName.pdf"; // Creates a file instance with filepath
  final file = File(filePath);
  await file.writeAsBytes(byteList);
  await OpenDocument.openDocument(filePath: filePath);
}


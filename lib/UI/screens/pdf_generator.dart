import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:intl/intl.dart';

Future<void> generatePdf(
    QueryDocumentSnapshot doc,
    List<Map<String, dynamic>> parts,
    List<Map<String, dynamic>> labour,
    double totalCost) async {
  // Extract data from Firestore document
  Map<String, dynamic> dataAsMap = doc.data() as Map<String, dynamic>;

  String customerName = dataAsMap["customer_name"] ?? "N/A";
  String rtoNumber = dataAsMap["car_number"] ?? "N/A";
  String carModel = dataAsMap["car_model"] ?? "N/A";
  String year = dataAsMap["year"]?.toString() ?? "N/A";

  // Create a new PDF document
  final pdf = pw.Document();

  // Process parts and labor data
  final processedParts = parts
      .map((part) => {
            'description': part['partName'],
            'mrp': part['amount'].toString(),
            'qty': part['quantity'].toString(),
            'total': (part['amount'] * part['quantity']).toString()
          })
      .toList();

  final processedLabour = labour
      .map(
          (lab) => {'description': lab['name'], 'cost': lab['cost'].toString()})
      .toList();

  // Calculate total costs
  final totalPartsCost = processedParts.fold<double>(0, (sum, part) {
    final total = double.tryParse(part['total'] ?? '0') ?? 0;
    return sum + total;
  });

  final totalLabourCost = processedLabour.fold<double>(0, (sum, lab) {
    final cost = double.tryParse(lab['cost'] ?? '0') ?? 0;
    return sum + cost;
  });

  final totalEstimate = totalPartsCost + totalLabourCost;

  // Heights of different sections
  const double headerHeight = 70;
  const double textHeight = 30;
  const double tableRowHeight = 35;
  const double spacingHeight = 20;

  // Calculate the total height of the content
  double contentHeight = 0;
  contentHeight += headerHeight;
  contentHeight += textHeight * 4;
  contentHeight += spacingHeight;
  contentHeight += headerHeight;
  contentHeight += processedParts.length * tableRowHeight;
  contentHeight += spacingHeight;
  contentHeight += tableRowHeight;
  contentHeight += spacingHeight;
  contentHeight += processedLabour.length * tableRowHeight;
  contentHeight += spacingHeight;
  contentHeight += tableRowHeight;
  contentHeight += spacingHeight;
  contentHeight += headerHeight;
  contentHeight += headerHeight * 2;

  // Define the page height slightly larger than the content height
  double pageHeight = contentHeight + 60;

  final pageSize = PdfPageFormat(PdfPageFormat.a4.width, pageHeight);

  // Get current date
  String formattedDate = DateFormat('d MMM yyyy').format(DateTime.now());

  pdf.addPage(
    pw.Page(
      pageFormat: pageSize,
      build: (pw.Context context) {
        return pw.Padding(
          padding: pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Mr.$customerName',
                            style: pw.TextStyle(fontSize: 30)),
                        pw.SizedBox(height: 5),
                        pw.Text('$rtoNumber',
                            style: pw.TextStyle(fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Mekit Garage', style: pw.TextStyle(fontSize: 27)),
                    pw.SizedBox(height: 10),
                    pw.Text('Job: Painting', style: pw.TextStyle(fontSize: 20)),
                    pw.SizedBox(height: 10),
                    pw.Text('Odo: 27680 KMs',
                        style: pw.TextStyle(fontSize: 20)),
                    pw.SizedBox(height: 10),
                    pw.Text('Date: $formattedDate',
                        style: pw.TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                headerHeight: 35,
                cellHeight: 35,
                cellAlignment: pw.Alignment.centerLeft,
                headerStyle:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(fontSize: 18),
                headers: ['Item Description', 'MRP', 'Qty.', 'Total'],
                data: processedParts
                    .map((part) => [
                          part['description'],
                          'Rs.${part['mrp']}',
                          part['qty'],
                          'Rs.${part['total']}'
                        ])
                    .toList(),
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Total Parts Estimate: Rs.$totalPartsCost',
                    style: pw.TextStyle(fontSize: 18)),
              ),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                headerHeight: 35,
                cellHeight: 35,
                cellAlignment: pw.Alignment.centerLeft,
                headerStyle:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(fontSize: 18),
                headers: ['Labour', 'Cost'],
                data: processedLabour
                    .map((lab) => [lab['description'], 'Rs.${lab['cost']}'])
                    .toList(),
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Total Estimate: Rs.$totalEstimate',
                    style: pw.TextStyle(fontSize: 18)),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Customer Note:',
                        style: pw.TextStyle(fontSize: 20)),
                    pw.Text('• NOTE', style: pw.TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  // Save PDF to the device
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/example.pdf');
  await file.writeAsBytes(await pdf.save());

  // Open the PDF file
  OpenFile.open(file.path);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:intl/intl.dart';

Future<void> generatePdf(QueryDocumentSnapshot doc) async {
  // Extract data from Firestore document
  Map<String, dynamic> dataAsMap = doc.data() as Map<String, dynamic>;

  String customerName = dataAsMap["customer_name"] ?? "N/A";
  String rtoNumber = dataAsMap["rto_number"] ?? "N/A";
  String model = dataAsMap["car_model"] ?? "N/A";
  String year = dataAsMap["year"]?.toString() ?? "N/A";

  // Create a new PDF document
  final pdf = pw.Document();

  // Process parts and labor data
  final parts = (dataAsMap["parts"] as List<dynamic>?)
      ?.map((part) => {
            'description': part['name'] ?? "Unknown",
            'mrp': part['mrp']?.toString() ?? "0",
            'qty': part['quantity']?.toString() ?? "0",
            'total': part['total']?.toString() ?? "0"
          })
      .toList();

  final labour = (dataAsMap["labour"] as List<dynamic>?)
      ?.map((lab) => {
            'description': lab['name'] ?? "Unknown",
            'cost': lab['cost']?.toString() ?? "0"
          })
      .toList();

  // Calculate total costs
  final totalPartsCost = parts?.fold(0, (sum, part) {
        final total = int.tryParse(part['total'] ?? '0') ?? 0;
        return sum + total;
      }) ??
      0;

  final totalLabourCost = labour?.fold(0, (sum, lab) {
        final cost = int.tryParse(lab['cost'] ?? '0') ?? 0;
        return sum + cost;
      }) ??
      0;

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
  contentHeight += (parts?.length ?? 0) * tableRowHeight;
  contentHeight += spacingHeight;
  contentHeight += tableRowHeight;
  contentHeight += spacingHeight;
  contentHeight += (labour?.length ?? 0) * tableRowHeight;
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
                            style: const pw.TextStyle(fontSize: 40)),
                        pw.SizedBox(height: 5),
                        pw.Text('$rtoNumber',
                            style: const pw.TextStyle(fontSize: 30)),
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
                    pw.Text('Mekit Garage', style: pw.TextStyle(fontSize: 40)),
                    pw.SizedBox(height: 10),
                    pw.Text('Job: Painting', style: pw.TextStyle(fontSize: 30)),
                    pw.SizedBox(height: 10),
                    pw.Text('Odo: 27680 KMs',
                        style: pw.TextStyle(fontSize: 30)),
                    pw.SizedBox(height: 10),
                    pw.Text('Date: $formattedDate',
                        style: pw.TextStyle(fontSize: 30)),
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
                data: parts
                        ?.map((part) => [
                              part['description'],
                              '₹${part['mrp']}',
                              part['qty'],
                              '₹${part['total']}'
                            ])
                        .toList() ??
                    [],
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Total Parts Estimate: ₹$totalPartsCost',
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
                headers: ['Labour', '', '', ''],
                data: labour
                        ?.map((lab) =>
                            [lab['description'], '', '', '₹${lab['cost']}'])
                        .toList() ??
                    [],
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Total Estimate: ₹$totalEstimate',
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
              pw.SizedBox(height: 16),
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Mechanic Remarks:',
                        style: pw.TextStyle(fontSize: 20)),
                    pw.Text('• NOTE', style: pw.TextStyle(fontSize: 18)),
                  ],
                ),
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
                    pw.Text('For any help or assistance,',
                        style: pw.TextStyle(fontSize: 18)),
                    pw.Text('please contact us at:',
                        style: pw.TextStyle(fontSize: 18)),
                    pw.Text('Mekit Garage', style: pw.TextStyle(fontSize: 18)),
                    pw.Text('Phone: +91 89898 89898',
                        style: pw.TextStyle(fontSize: 18)),
                    pw.Text(
                        'Address: This is a boring kinda place, just a lot of talking about cars, not for normal people.',
                        style: pw.TextStyle(fontSize: 18)),
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

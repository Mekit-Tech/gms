import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'dart:io';

Future generatePdf(
    QueryDocumentSnapshot doc,
    List<Map<String, dynamic>> parts,
    List<Map<String, dynamic>> labour,
    double totalCost,
    String uid,
    String customerId,
    String jobId) async {
  try {
    // Extract data from Firestore document
    Map<String, dynamic> dataAsMap = doc.data() as Map<String, dynamic>;

    String customerName = dataAsMap["customer_name"] ?? "N/A";
    String rtoNumber = dataAsMap["car_number"] ?? "N/A";

    // Fetch garage data
    String garageName = "N/A";
    String garageLogoUrl = "";
    final garageDoc =
        await FirebaseFirestore.instance.collection('garages').doc(uid).get();
    final garageData = garageDoc.data();
    if (garageData != null) {
      garageName = garageData['name'] ?? "N/A";
      garageLogoUrl = garageData['logo'] ?? "";
    }

    // Fetch job data
    String primaryJob = "N/A";
    String odoReading = "N/A";
    String customerNote = "N/A";
    final jobDoc = await FirebaseFirestore.instance
        .collection('garages')
        .doc(uid)
        .collection('customers')
        .doc(customerId)
        .collection('jobs')
        .doc(jobId)
        .get();

    final jobData = jobDoc.data();
    if (jobData != null) {
      primaryJob = jobData['primary_job'] ?? "N/A";
      odoReading = jobData['current_odo']?.toString() ?? "N/A";
      customerNote = jobData['customer_note'] ?? "";
    }

    // Fetch logo image
    Uint8List? garageLogo;
    if (garageLogoUrl.isNotEmpty) {
      final response = await http.get(Uri.parse(garageLogoUrl));
      if (response.statusCode == 200) {
        garageLogo = response.bodyBytes;
      }
    }

    // Create a new PDF document
    final pdf = pw.Document();

    // Load custom font
    final fontData = await rootBundle.load('assets/fonts/DMSans-Bold.ttf');
    final customFont = pw.Font.ttf(fontData);

    // Process parts and labor data
    final processedParts = parts
        .map((part) => {
              'description': part['partName'] ?? "N/A",
              'mrp': part['amount']?.toStringAsFixed(0) ?? "0",
              'qty': part['quantity']?.toString() ?? "0",
              'total': ((part['amount'] ?? 0) * (part['quantity'] ?? 0))
                  .toStringAsFixed(0)
            })
        .toList();

    final processedLabour = labour
        .map((lab) => {
              'description': lab['laborName'] ?? "N/A",
              'cost': (lab['cost'] ?? 0).toStringAsFixed(0)
            })
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
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
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
                              style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 30)), // Use custom font here
                          pw.SizedBox(height: 5),
                          pw.Text('$rtoNumber',
                              style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 20)), // Use custom font here
                        ],
                      ),
                      if (garageLogo != null)
                        pw.Image(pw.MemoryImage(garageLogo), width: 100),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('$garageName',
                          style: pw.TextStyle(
                              font: customFont,
                              fontSize: 27)), // Use custom font here
                      pw.SizedBox(height: 10),
                      pw.Text('Job: $primaryJob',
                          style: pw.TextStyle(
                              font: customFont,
                              fontSize: 20)), // Use custom font here
                      pw.SizedBox(height: 10),
                      pw.Text('Odo: $odoReading KMs',
                          style: pw.TextStyle(
                              font: customFont,
                              fontSize: 20)), // Use custom font here
                      pw.SizedBox(height: 10),
                      pw.Text('Date: $formattedDate',
                          style: pw.TextStyle(
                              font: customFont,
                              fontSize: 20)), // Use custom font here
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  headerHeight: 35,
                  cellHeight: 35,
                  cellAlignment: pw.Alignment.centerLeft,
                  headerStyle: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 18),
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
                pw.Text('Total Parts : Rs.$totalPartsCost',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  headerHeight: 35,
                  cellHeight: 35,
                  cellAlignment: pw.Alignment.centerLeft,
                  headerStyle: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 18),
                  headers: ['Labour', 'Cost'],
                  data: processedLabour
                      .map((lab) => [lab['description'], 'Rs.${lab['cost']}'])
                      .toList(),
                ),
                pw.SizedBox(height: 16),
                pw.Text('Total Labour : Rs.$totalLabourCost',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text('Total : Rs.$totalEstimate',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                if (customerNote.isNotEmpty)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Customer Note:',
                            style: const pw.TextStyle(fontSize: 20)),
                        pw.Text(customerNote,
                            style: const pw.TextStyle(fontSize: 18)),
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
    final file = File('${directory.path}/order.pdf');
    await file.writeAsBytes(await pdf.save());

    // Open the share menu
    await Share.shareFiles([file.path], text: 'Here is your receipt PDF');
  } catch (e) {
    print("Error generating PDF: $e");
  }
}

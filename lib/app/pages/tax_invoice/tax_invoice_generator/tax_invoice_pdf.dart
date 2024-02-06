import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../sales_billing.dart';


class TaxInvoicePDF extends StatefulWidget {
  static String SellerAddress = "";
  static String SellerDistrict = "";
  static String BuyerAddress = "";
  static String BuyerDistrict = "";
  static String Invoice_num = "";

  const TaxInvoicePDF({super.key});

  @override
  State<TaxInvoicePDF> createState() => _TaxInvoicePDFState();
}

class _TaxInvoicePDFState extends State<TaxInvoicePDF> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PdfAddressBuyer();
    PdfAddressSeller();
    date();
  }

  String actualDate = '';
  date() {
    setState(() {
      var now = DateTime.now();
      var currentDate = DateFormat('dd/MM/yyyy');
      actualDate = currentDate.format(now);
    });
  }

  PdfAddressBuyer() async {
    await FirebaseFirestore.instance
        .collection('company_info')
        .doc('0b9d9ff7-90b4-4208-a5aa-42b102d5d72a')
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        final Map<String, dynamic> doc =
            documentSnapshot.data() as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          TaxInvoicePDF.BuyerAddress = doc['legal_address'][0].toString();

          TaxInvoicePDF.BuyerDistrict = doc['legal_address'][1].toString();
        });
      }
    });
  }

  PdfAddressSeller() async {
    await FirebaseFirestore.instance
        .collection('snadhut')
        .doc('j100123d-c15b-4e45-b00e-4aec7d2a7353')
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        final Map<String, dynamic> doc =
            documentSnapshot.data() as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          TaxInvoicePDF.Invoice_num = doc['gstin_no'].toString();
          TaxInvoicePDF.SellerDistrict = doc[''].toString();
          TaxInvoicePDF.SellerAddress = doc['legal_address'][0].toString();
        });
      }
    });
  }

  final doc = pw.Document();

  @override
  Widget build(BuildContext context) {
    Future<void> _generatePdf() async {
      final picker = ImagePicker();
      final pdf = pw.Document();

      final ByteData image = await rootBundle.load('assets/image/sandhut.png');
      Uint8List imageData = (image).buffer.asUint8List();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Container(
                  height: 720,
                  width: 480,
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1)),
                  child: pw.Column(children: [
                    pw.Row(children: [
                      pw.Container(
                        width: 240,
                        height: 50,
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.black, width: 1)),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Image(pw.MemoryImage(imageData)),
                          ],
                        ),
                      ),
                      pw.Container(
                          height: 50,
                          width: 240,
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                  color: PdfColors.black, width: 1)),
                          child: pw.Column(children: [
                            pw.Row(children: [
                              pw.Container(
                                height: 25,
                                width: 120,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                        color: PdfColors.black, width: 1)),
                                child: pw.Text(TaxInvoicePDF.Invoice_num,
                                    textAlign: pw.TextAlign.center),
                                padding: pw.EdgeInsets.all(8),
                              ),
                              pw.Container(
                                height: 25,
                                width: 120,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                        color: PdfColors.black, width: 1)),
                                child: pw.Text(actualDate,
                                    textAlign: pw.TextAlign.center),
                                padding: pw.EdgeInsets.all(8),
                              ),
                            ]),
                            pw.Container(
                              height: 25,
                              width: 240,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child: pw.Text(
                                'Mode Of Pay : CASH',
                              ),
                              padding: pw.EdgeInsets.all(8),
                            ),
                          ]))
                    ]),
                    pw.Row(children: [
                      pw.Container(
                        height: 120,
                        width: 240,
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.black, width: 1)),
                        child: pw.Text(
                          'Seller: '
                          '${TaxInvoicePDF.SellerAddress}\nKarnataka\nIndia\n562310',
                          maxLines: 10,
                          overflow: pw.TextOverflow.clip,
                          style: pw.TextStyle(fontSize: 10),
                        ),
                        padding: pw.EdgeInsets.all(8),
                      ),
                      pw.Container(
                        height: 120,
                        width: 240,
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.black, width: 1)),
                        child: pw.Text(
                          'Buyer: ${TaxInvoicePDF.BuyerAddress}\nKarnataka\nIndia\n562310',
                          maxLines: 10,
                          overflow: pw.TextOverflow.clip,
                          style: pw.TextStyle(fontSize: 10),
                        ),
                        padding: pw.EdgeInsets.all(8),
                      ),
                    ]),
                    pw.Row(
                      children: [
                        pw.Column(children: [
                          pw.Row(children: [
                            pw.Container(
                              height: 20,
                              width: 30,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child: pw.Text('S.no',
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 20,
                              width: 210,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child: pw.Text('Description of Goods/Service',
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 20,
                              width: 48,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child: pw.Text('Nac No',
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 20,
                              width: 48,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child: pw.Text('Quantity',
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 20,
                              width: 48,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child: pw.Text('Rate',
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 20,
                              width: 48,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child: pw.Text('Tax',
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 20,
                              width: 48,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child: pw.Text('Amount',
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                          ]),
                          pw.Row(children: [
                            pw.Container(
                              height: 340,
                              width: 30,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child:
                                  pw.Text('1', textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 340,
                              width: 210,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child: pw.Text('Material',
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 340,
                              width: 48,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child: pw.Text('233551',
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 340,
                              width: 48,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child: pw.Text('Good',
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 340,
                              width: 48,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                    color: PdfColors.black, width: 1),
                              ),
                              child: pw.Text(
                                '230',
                                textAlign: pw.TextAlign.center,
                              ),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 340,
                              width: 48,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child:
                                  pw.Text('9%', textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 340,
                              width: 48,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.black, width: 1)),
                              child: pw.Text('230',
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                          ]),
                        ])
                      ],
                    ),
                    pw.Row(children: [
                      pw.Container(
                        height: 130,
                        width: 350,
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.black, width: 1)),
                        child: pw.Column(children: [
                          pw.Row(children: [
                            pw.Container(
                              height: 20,
                              width: 100,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                color: PdfColors.black,
                                width: 1,
                              )),
                              child: pw.Text("TAXABLE AMT",
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 20,
                              width: 60,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                color: PdfColors.black,
                                width: 1,
                              )),
                              child: pw.Text("CGST",
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 20,
                              width: 60,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                color: PdfColors.black,
                                width: 1,
                              )),
                              child: pw.Text("SGST",
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            ),
                            pw.Container(
                              height: 20,
                              width: 60,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                color: PdfColors.black,
                                width: 1,
                              )),
                              child: pw.Text("IGST",
                                  textAlign: pw.TextAlign.center),
                              padding: pw.EdgeInsets.all(1.5),
                            )
                          ]),
                          pw.Column(children: [
                            pw.Row(children: [
                              pw.Container(
                                height: 20,
                                width: 100,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 1,
                                )),
                                child: pw.Text("100.00",
                                    textAlign: pw.TextAlign.center),
                                padding: pw.EdgeInsets.all(1.5),
                              ),
                              pw.Container(
                                height: 20,
                                width: 60,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 1,
                                )),
                                child: pw.Text( SalesBilling.cgst,
                                    textAlign: pw.TextAlign.center),
                                padding: pw.EdgeInsets.all(1.5),
                              ),
                              pw.Container(
                                height: 20,
                                width: 60,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 1,
                                )),
                                child: pw.Text( SalesBilling.gstin,
                                    textAlign: pw.TextAlign.center),
                                padding: pw.EdgeInsets.all(1.5),
                              ),
                              pw.Container(
                                height: 20,
                                width: 60,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 1,
                                )),
                                child: pw.Text( SalesBilling.igst,
                                    textAlign: pw.TextAlign.center),
                                padding: pw.EdgeInsets.all(1.5),
                              )
                            ]),
                            pw.Column(children: [
                              pw.Row(children: [
                                pw.Container(
                                  height: 20,
                                  width: 100,
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 1,
                                  )),
                                  child: pw.Text("100.00",
                                      textAlign: pw.TextAlign.center),
                                  padding: pw.EdgeInsets.all(1.5),
                                ),
                                pw.Container(
                                  height: 20,
                                  width: 60,
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 1,
                                  )),
                                  child: pw.Text("18.00",
                                      textAlign: pw.TextAlign.center),
                                  padding: pw.EdgeInsets.all(1.5),
                                ),
                                pw.Container(
                                  height: 20,
                                  width: 60,
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: PdfColors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: pw.Text("18.00",
                                      textAlign: pw.TextAlign.center),
                                  padding: pw.EdgeInsets.all(1.5),
                                ),
                                pw.Container(
                                  height: 20,
                                  width: 60,
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                    color: PdfColors.black,
                                    width: 1,
                                  )),
                                  child: pw.Text("18.00",
                                      textAlign: pw.TextAlign.center),
                                  padding: pw.EdgeInsets.all(1.5),
                                ),
                              ]),
                              pw.SizedBox(height: 5,),
                              pw.Column(children: [ pw.Padding(
                                padding: pw.EdgeInsets.symmetric(horizontal: 5), // Add your desired vertical padding
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.center,
                                  children: [
                                    pw.Text('Kotak Mahindra Bank'),
                                  ],
                                ),
                              ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(horizontal: 5), // Add your desired vertical padding
                                  child: pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.center,
                                    children: [
                                      pw.Text('Account No'),
                                      pw.Text(':7353119898'),
                                    ],
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(horizontal: 5), // Add your desired vertical padding
                                  child: pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.center,
                                    children: [
                                      pw.Text('IFSC'),
                                      pw.Text(':KKBK0008262'),
                                    ],
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(horizontal: 5), // Add your desired vertical padding
                                  child: pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.center,
                                    children: [
                                      pw.Text('Branch'),
                                      pw.Text(':Kadabagere'),
                                    ],
                                  ),
                                ),

                              ])

                            ])
                          ])
                        ]),

                      ),
                      pw.Container(
                        height: 130,
                        width: 130,
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.black, width: 1)),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Container(
                                child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.center,
                                    children: [
                                      pw.Row(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Text('Gross Total'),
                                            pw.Text(': 465'),
                                          ]),
                                      pw.Row(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Text('Discount'),
                                            pw.Text(': 100'),
                                          ]),
                                      pw.Row(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Text('Cost'),
                                            pw.Text(': 365'),
                                          ]),
                                      pw.Row(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Text('SGST'),
                                            pw.Text(': 9%'),
                                          ]),
                                      pw.Row(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Text('IGST'),
                                            pw.Text(': 0%'),
                                          ]),
                                      pw.Row(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          children: [
                                            pw.Text('Round Off'),
                                            pw.Text(': 365.00'),
                                          ]),
                                    ]),
                                padding: pw.EdgeInsets.all(10),
                              ),
                              pw.Container(
                                height: 25,
                                width: 130,
                                decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                        color: PdfColors.black, width: 1)),
                                child: pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text('Total Amount',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                      pw.Text(': 365.00',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                    ]),
                              ),
                            ]),
                      ),
                    ]),
                    pw.Row(children: [
                      pw.Container(
                        height: 30,
                        width: 480,
                        decoration: pw.BoxDecoration(
                          border:
                              pw.Border.all(color: PdfColors.black, width: 1),
                        ),
                        child: pw.Text(
                          'AMOUNT IN WORDS: One Hundred Rupees Only ',
                        ),
                        padding: pw.EdgeInsets.all(5),
                      ),
                    ]),
                    pw.Row(children: [
                      pw.Column(children: [
                        pw.Container(
                          height: 30,
                          width: 480,
                          decoration: pw.BoxDecoration(
                            border:
                                pw.Border.all(color: PdfColors.black, width: 1),
                          ),
                          child: pw.Row(children: [
                            pw.Row(children: [ pw.Text(
                              'Goods Received in Goods Condition ',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),]),
                          ]),

                          padding: pw.EdgeInsets.all(10),
                        ),
                      ]),
                    ])
                  ]),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    } // Page

    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Example'),
        actions: [IconButton(
            onPressed: (){
            },
            icon: Icon(Icons.picture_as_pdf_sharp))],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _generatePdf,
          child: Text('Generate PDF'),
        ),
      ),
    );





  }
}

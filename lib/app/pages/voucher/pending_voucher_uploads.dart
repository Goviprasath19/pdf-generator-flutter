import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';
import '../../../widgets/constrans.dart';
import '../../../widgets/default_loading.dart';
import 'dart:html' as html;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../tax_invoice/sales_billing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../widgets/default_loading.dart';

class PendingFilesUpload extends StatefulWidget {
  const PendingFilesUpload({super.key});

  @override
  State<PendingFilesUpload> createState() => _PendingFilesUploadState();
}

class _PendingFilesUploadState extends State<PendingFilesUpload> {
  bool _defaultLoading = false;

  // Image Pick and Rename Section -------------------------
  String imageUrl = '';
  TextEditingController _fileNameController = TextEditingController();
  void _imagePicker() {
    _pickImageAndUpload(context);
  }

  Future<void> _pickImageAndUpload(BuildContext context) async {
    final picker = ImagePicker();

    // Check if the platform is Flutter Web.
    if (kIsWeb) {
      // Use the file input for Flutter Web.
      final html.FileUploadInputElement input = html.FileUploadInputElement();
      input.accept = 'image/*'; // Accept image files only.
      input.click();

      input.onChange.listen((event) async {
        if (input.files!.length > 0) {
          final html.File file = input.files![0];
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((event) async {
            setState(() {
              _defaultLoading = true;
            });
            final imageBytes = reader.result as Uint8List;
            await _uploadImage(imageBytes);
            // Set the file name in the TextEditingController
            _fileNameController.text = file.name;
            setState(() {
              _defaultLoading = false;
            });
          });
        }
      });
    } else {
      // Use the image picker for mobile platforms (Android and iOS).
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _defaultLoading = true;
        });
        File imageFile = File(pickedImage.path);
        final imageBytes = await imageFile.readAsBytes();
        await _uploadImage(imageBytes);

        // Set the file name in the TextEditingController
        _fileNameController.text = imageFile.path.split('/').last;
        setState(() {
          _defaultLoading = false;
        });
      }
    }
    setState(() {
      _defaultLoading = false;
    });
  }

  Future<void> _uploadImage(Uint8List imageBytes) async {
    try {
      DateTime now = DateTime.now();
      String fileName = DateFormat('dd-MMM-yyyy').format(now);
      //String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('/documents/vouchers/vouchers-$fileName.jpg');

      // Upload the image to Firebase Storage
      await ref.putData(imageBytes);

      // Get the download URL of the uploaded image

      imageUrl = await ref.getDownloadURL();

      // Save the download URL in Firestore
      // await FirebaseFirestore.instance
      //     .collection('imgUrl')
      //     .add({'url': imageUrl});

      print('Image uploaded successfully.');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  // Future<void> _fetchCompanyInfo() async {
  //   await FirebaseFirestore.instance
  //       .collection('company_info')
  //       .where('legal_name', isEqualTo: SalesBilling.dropdownValueTaxBillToCompany)
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
  //       if (documentSnapshot.exists) {
  //         setState(() {
  //           _sellerCompanyUUID = documentSnapshot.id;
  //         });
  //         setState(() {
  //           _defaultLoading = false;
  //         });
  //       } else {
  //         setState(() {
  //           _defaultLoading = false;
  //         });
  //         print('Something Went Wrong');
  //       }
  //     }
  //   });
  // }
  // Image Pick and Rename Section -------------------------


  String voucherPrintNo = '';
  late String _date;
  String amountInWords = '';
  String voucherTo = '';
  String beingTowards = '';
  String modeOfPayment = '';
  String voucherUUID = '';
  int amount = 0;
  String voucherNO = '';
  bool printDuplicate = false;

  // Future<void> _addVoucherImageUpload() async {
  //   await FirebaseFirestore.instance.collection('voucher').doc(uuid).update({
  //     'documentUrl': imageUrl.isEmpty ?'N/A':imageUrl,
  //   });
  //   setState(() {
  //     _defaultLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {

    Future<void> _generatePdf() async {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(50),
            orientation: pw.PageOrientation.portrait,
          ),
          build: (pw.Context context) {
            return printDuplicate
                ? pw.Container(
              decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border:
                  pw.Border.all(color: PdfColors.black, width: 2)),
              child: pw.Padding(
                padding: pw.EdgeInsets.all(10),
                child: pw.Column(
                  children: [
                    pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment:
                            pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'SANDHUT INDIA PRIVET LIMITED',
                                style: pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9),
                              ),
                              pw.SizedBox(
                                height: 5,
                              ),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    'GSTIN: 29ABKCS1628N1ZP',
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8),
                                  ),
                                  pw.SizedBox(
                                    width: 3,
                                  ),
                                  pw.Text(
                                    'CIN:  U72900KA2023PTC170142',
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8),
                                  ),
                                ],
                              ),
                              pw.SizedBox(
                                height: 3,
                              ),
                              pw.Text(
                                'No. 23 Anugraha Enclave ,Nandagokula Nilaya,',
                                style: pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8),
                              ),
                              pw.Text(
                                'Kadabegere, Magadi Main Rd ,Nr Janpriya Bangalore,',
                                style: pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8),
                              ),
                              pw.Text(
                                'Karnataka, India, 562130',
                                style: pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8),
                              ),
                            ],
                          ),
                          pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              crossAxisAlignment:
                              pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'PAYMENT VOUCHER',
                                  style: pw.TextStyle(
                                      color: PdfColors.black,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10),
                                ),
                                pw.Text(
                                  'Serial No: $voucherNO',
                                  style: pw.TextStyle(
                                      color: PdfColors.black,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 6),
                                ),
                              ])
                        ]),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Text(
                      'Original Voucher Copy',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 7),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Voucher No:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            voucherPrintNo,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                          pw.Container(
                            height: 20,
                            width: 1,
                            color: PdfColors.black,
                          ),
                          pw.Text(
                            'Date:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            _date,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Mode of Payment:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            modeOfPayment,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Amount:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            'Rs.${amount}/-',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                          pw.Container(
                            height: 20,
                            width: 1,
                            color: PdfColors.black,
                          ),
                          pw.Text(
                            'Amount In words:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            amountInWords.toUpperCase().toString(),
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'To whom:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            voucherTo,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Being Towards:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            beingTowards,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Approved By:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Container(
                            height: 30,
                            width: 2,
                            color: PdfColors.black,
                          ),
                          pw.Text(
                            'Paid Seal:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                          pw.Container(
                            height: 30,
                            width: 2,
                            color: PdfColors.black,
                          ),
                          pw.Text(
                            'Receiver\s Signature:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 30),
                    pw.Text(
                      '--------------------------------------------------------------------------------------- Cut Here-----------------------------------------------------------------------------------------------',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 7),
                    ),
//---------------------Duplicate Copy ---------------------------------------------
                    pw.SizedBox(height: 30),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment:
                            pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'SANDHUT INDIA PRIVET LIMITED',
                                style: pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9),
                              ),
                              pw.SizedBox(
                                height: 5,
                              ),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    'GSTIN: 29ABKCS1628N1ZP',
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8),
                                  ),
                                  pw.SizedBox(
                                    width: 3,
                                  ),
                                  pw.Text(
                                    'CIN:  U72900KA2023PTC170142',
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8),
                                  ),
                                ],
                              ),
                              pw.SizedBox(
                                height: 3,
                              ),
                              pw.Text(
                                'No. 23 Anugraha Enclave ,Nandagokula Nilaya,',
                                style: pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8),
                              ),
                              pw.Text(
                                'Kadabegere, Magadi Main Rd ,Nr Janpriya Bangalore,',
                                style: pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8),
                              ),
                              pw.Text(
                                'Karnataka, India, 562130',
                                style: pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8),
                              ),
                            ],
                          ),
                          pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              crossAxisAlignment:
                              pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'PAYMENT VOUCHER',
                                  style: pw.TextStyle(
                                      color: PdfColors.black,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10),
                                ),
                                pw.Text(
                                  'Serial No: $voucherNO',
                                  style: pw.TextStyle(
                                      color: PdfColors.black,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 6),
                                ),
                              ])
                        ]),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Text(
                      'Receivers Voucher Copy',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 7),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Voucher No:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            voucherPrintNo,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                          pw.Container(
                            height: 20,
                            width: 1,
                            color: PdfColors.black,
                          ),
                          pw.Text(
                            'Date:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            _date,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Mode of Payment:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            modeOfPayment,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Amount:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            'Rs.${amount}/-',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                          pw.Container(
                            height: 20,
                            width: 1,
                            color: PdfColors.black,
                          ),
                          pw.Text(
                            'Amount In words:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            amountInWords.toUpperCase().toString(),
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'To whom:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            voucherTo,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Being Towards:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            beingTowards,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Approved By:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Container(
                            height: 30,
                            width: 2,
                            color: PdfColors.black,
                          ),
                          pw.Text(
                            'Paid Seal:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                          pw.Container(
                            height: 30,
                            width: 2,
                            color: PdfColors.black,
                          ),
                          pw.Text(
                            'Receiver\s Signature:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),

//---------------------Duplicate Copy ---------------------------------------------
                  ],
                ),
              ),
            )
                :
            // Only Original Copy of Print
            pw.Container(
              height: 350,
              decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(
                      color: PdfColors.black, width: 2)),
              child: pw.Padding(
                padding: pw.EdgeInsets.all(10),
                child: pw.Column(
                  children: [
                    pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment:
                            pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'SANDHUT INDIA PRIVET LIMITED',
                                style: pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9),
                              ),
                              pw.SizedBox(
                                height: 5,
                              ),
                              pw.Row(
                                children: [
                                  pw.Text(
                                    'GSTIN: 29ABKCS1628N1ZP',
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8),
                                  ),
                                  pw.SizedBox(
                                    width: 3,
                                  ),
                                  pw.Text(
                                    'CIN:  U72900KA2023PTC170142',
                                    style: pw.TextStyle(
                                        color: PdfColors.black,
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8),
                                  ),
                                ],
                              ),
                              pw.SizedBox(
                                height: 3,
                              ),
                              pw.Text(
                                'No. 23 Anugraha Enclave ,Nandagokula Nilaya,',
                                style: pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8),
                              ),
                              pw.Text(
                                'Kadabegere, Magadi Main Rd ,Nr Janpriya Bangalore,',
                                style: pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8),
                              ),
                              pw.Text(
                                'Karnataka, India, 562130',
                                style: pw.TextStyle(
                                    color: PdfColors.black,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8),
                              ),
                            ],
                          ),
                          pw.Column(
                              mainAxisAlignment:
                              pw.MainAxisAlignment.end,
                              crossAxisAlignment:
                              pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  'PAYMENT VOUCHER',
                                  style: pw.TextStyle(
                                      color: PdfColors.black,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10),
                                ),
                                pw.Text(
                                  'Serial No: $voucherNO',
                                  style: pw.TextStyle(
                                      color: PdfColors.black,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 6),
                                ),
                              ])
                        ]),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Text(
                      'Original Voucher Copy',
                      style: pw.TextStyle(
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 7),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Voucher No:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            voucherPrintNo,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                          pw.Container(
                            height: 20,
                            width: 1,
                            color: PdfColors.black,
                          ),
                          pw.Text(
                            'Date:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            _date,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Mode of Payment:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            modeOfPayment,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Amount:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            'Rs.${amount}/-',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                          pw.Container(
                            height: 20,
                            width: 1,
                            color: PdfColors.black,
                          ),
                          pw.Text(
                            'Amount In words:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            amountInWords.toUpperCase().toString(),
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'To whom:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            voucherTo,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Being Towards:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Text(
                            beingTowards,
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                      color: PdfColors.black,
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      child: pw.Row(
                        mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Approved By:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                          pw.Container(
                            height: 30,
                            width: 2,
                            color: PdfColors.black,
                          ),
                          pw.Text(
                            'Paid Seal:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9),
                          ),
                          pw.Container(
                            height: 30,
                            width: 2,
                            color: PdfColors.black,
                          ),
                          pw.Text(
                            'Receiver\s Signature:',
                            style: pw.TextStyle(
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }));
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    }

    return _defaultLoading
        ? DefaultLoading()
        : Scaffold(
            backgroundColor: Colors.grey.shade200,
            body: ListView(
              children: [
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('voucher')
                        .where('documentUrl', isEqualTo: 'N/A')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      print(snapshot.hasData);
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: smartYellow,
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      child: Title(
                                          color: Colors.black,
                                          child: Text(
                                            'Add Voucher Pending Upload',
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ))),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: printDuplicate,
                                        onChanged: (value) {
                                          setState(() {
                                            printDuplicate = !printDuplicate;
                                          });
                                        },
                                      ),
                                      SizedBox(width: 10),
                                      Text('Print Duplicate '),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(),
                              ListView.builder(
                                shrinkWrap : true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data.docs.length,
                                  itemBuilder: (context,index){
                                  DocumentSnapshot data = snapshot.data.docs[index];
                                  // amount = data['amount'];
                                  // amountInWords = data['amountInWords'];
                                  // voucherPrintNo = data['voucherPrintNo'];
                                  // voucherNO = data['voucherNO'];
                                  // voucherTo = data['voucherTo'];
                                  // beingTowards = data['beingTowards'];
                                  // modeOfPayment = data['modeOfPayment'];
                                  // String documentUrl = data['documentUrl'];
                                  Timestamp date = data['date'];
                                   DateTime _dateNow = date.toDate();
                                  voucherUUID = data.id;
                                  final convertedDate  = DateFormat('dd-MMM-yyyy').format(_dateNow);
                                  _date = DateFormat('dd-MMM-yyyy').format(_dateNow);
                                  return ListView(
                                    physics: ScrollPhysics(),
                                    shrinkWrap: true,
                                    children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('SHV No.:${data['voucherPrintNo']}'),
                                        Text('Date:${convertedDate}'),

                                        Flexible(
                                            child: IconButton(
                                                onPressed: () {
                                                  _imagePicker();
                                                },
                                                icon: Icon(Icons.upload))),
                                        Flexible(
                                            child: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    amount = data['amount'];
                                                    amountInWords = data['amountInWords'];
                                                    voucherPrintNo = data['voucherPrintNo'];
                                                    voucherNO = data['voucherNO'];
                                                    voucherTo = data['voucherTo'];
                                                    beingTowards = data['beingTowards'];
                                                    modeOfPayment = data['modeOfPayment'];
                                                    String documentUrl = data['documentUrl'];
                                                    Timestamp date = data['date'];
                                                    DateTime _dateNow = date.toDate();
                                                    voucherUUID = data.id;
                                                    final convertedDate  = DateFormat('dd-MMM-yyyy').format(_dateNow);
                                                    _date = DateFormat('dd-MMM-yyyy').format(_dateNow);
                                                  });
                                                  _generatePdf();
                                                }, icon: Icon(Icons.print)))
                                      ],
                                    ),
                                      Divider(),
                                    ],
                                  );
                              }),
                            ],
                          ),
                        );
                      }
                    }),
              ],
            ),
          );
  }
}


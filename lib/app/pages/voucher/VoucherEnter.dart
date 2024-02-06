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

class VoucherEnter extends StatefulWidget {
  const VoucherEnter({super.key});
  static String voucherNoGenerated = '';
  @override
  State<VoucherEnter> createState() => _VoucherEnterState();
}

class _VoucherEnterState extends State<VoucherEnter> {
  var uuid = '';
  String imageUrl = '';
  String reason = '';
  bool _defaultLoading = true;
  bool _submit = false;
  String _selectedValue = "";
  String _billCompany = 'SANDHUT INDIA PRIVATE LIMITED';
  TextEditingController _fileNameController = TextEditingController();
  TextEditingController _productsServicePriceController =
      TextEditingController();
  TextEditingController _toTextController = TextEditingController();
  TextEditingController _reasonTextController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    loading_();
    fetchBillingToCompany();
    _expenseTO();
    _sellerInfo();
    _productsServicePriceController.addListener(_updateAmountInWords);
    super.initState();
  }

  String selectedDate =
      DateFormat('dd-MMM-yyyy').format(DateTime.now()); // Default value

  final List<String> days =
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
  final List<Map<String, String>> months = [
    {'id': '01', 'name': 'Jan'},
    {'id': '02', 'name': 'Feb'},
    {'id': '03', 'name': 'Mar'},
    {'id': '04', 'name': 'Apr'},
    {'id': '05', 'name': 'May'},
    {'id': '06', 'name': 'Jun'},
    {'id': '07', 'name': 'Jul'},
    {'id': '08', 'name': 'Aug'},
    {'id': '09', 'name': 'Sep'},
    {'id': '10', 'name': 'Oct'},
    {'id': '11', 'name': 'Nov'},
    {'id': '12', 'name': 'Dec'},
  ];
  final List<String> years = List.generate(
      DateTime.now().year - 2023 + 1, (index) => (2023 + index).toString());

  void dispose() {
    _productsServicePriceController.removeListener(_updateAmountInWords);
    _productsServicePriceController.dispose();
    super.dispose();
  }

  loading_() {
    setState(() {
      _defaultLoading = true;
    });
  }

  void _refresh() {
    fetchBillingToCompany();
    _expenseTO();
    _sellerInfo();
  }

  var tax_invoice_num = '';
  var voucherNO = '';
  bool isEditing = true;
  Future<String> generateSequenceNumber() async {
    final DocumentReference document = FirebaseFirestore.instance
        .collection('voucher_number')
        .doc('invoice_counter');
    String sequenceNumber = '0';
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      print(snapshot.data());
      final currentNumber = data['counter'];
      sequenceNumber = (currentNumber + 1).toString().padLeft(6, '0');
      transaction.update(document, {'counter': currentNumber + 1});
    });
    setState(() {
      voucherNO = sequenceNumber;
    });

    return 'SHV' '/' +
        sequenceNumber +
        '/' '${DateTime.now().year}-${DateTime.now().year + 1}';
  }

  void fetchBillingToCompany() async {
    setState(() {
      _defaultLoading = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('company_info')
        .where('status', isEqualTo: 'active')
        .get();
    setState(() {
      SalesBilling.dropdownDataTaxBillTo = querySnapshot.docs
          .map((doc) => doc.get('legal_name').toString())
          .toList();
    });
    setState(() {
      _defaultLoading = false;
    });
  }

  _expenseTO() async {
    setState(() {
      _defaultLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('snadhut')
        .where('legal_name', isEqualTo: _billCompany)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.exists) {
          setState(() {
            SalesBilling.billFromCompanyUUID = documentSnapshot.id;
            SalesBilling.billFromCompanyName = documentSnapshot['legal_name'];
            SalesBilling.billFromCompanyAddress =
                documentSnapshot['legal_address'];
            SalesBilling.billFromCompanyTaxNo = documentSnapshot['tax_no'] == ''
                ? 'No Data'
                : documentSnapshot['tax_no'];
            SalesBilling.billFromCompanyGstinNo =
                documentSnapshot['gstin_no'] == ''
                    ? 'No Data'
                    : documentSnapshot['gstin_no'];
            SalesBilling.billFromCompanyPhoneNo =
                documentSnapshot['phone_no'].toString();
            SalesBilling.billFromCompanyEmailId = documentSnapshot['email'];
            SalesBilling.billFromCompanyWebsite =
                documentSnapshot['company_website'];
            SalesBilling.billFromCompanyBankinfo = documentSnapshot['bank'];
            SalesBilling.billFromCompanyNickName =
                documentSnapshot['nick_name'];
            _selectedValue = documentSnapshot['legal_name'];
          });
          setState(() {
            _defaultLoading = false;
          });
        } else {
          setState(() {
            _defaultLoading = false;
          });
          print('Something Went Wrong');
        }
      }
    });
  }

  _sellerInfo() async {
    setState(() {
      _defaultLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('company_info')
        .where('status', isEqualTo: 'active')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.exists) {
          setState(() {
            print('legal_name');
            print(documentSnapshot['legal_name']);
          });
          setState(() {
            _defaultLoading = false;
          });
        } else {
          setState(() {
            _defaultLoading = false;
          });
          print('Something Went Wrong');
        }
      }
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

  List<DropdownMenuItem<String>> get _dropdownTaxBillFrom {
    List<DropdownMenuItem<String>> fromBillData = [
      DropdownMenuItem(
          child: Text(SalesBilling.billFromCompanyName),
          value: SalesBilling.billFromCompanyName),
    ];
    return fromBillData;
  }

  List<String> paymentItems = ['UPI/Online', 'Cash', 'Net Banking'];
  String selectedPaymentValue = 'UPI/Online'; // Default selected item

  String _sellerCompanyUUID = '';

  Future<void> _fetchCompanyInfo() async {
    await FirebaseFirestore.instance
        .collection('company_info')
        .where('legal_name', isEqualTo: SalesBilling.dropdownValueTaxBillToCompany)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.exists) {
          setState(() {
            _sellerCompanyUUID = documentSnapshot.id;
          });
          setState(() {
            _defaultLoading = false;
          });
        } else {
          setState(() {
            _defaultLoading = false;
          });
          print('Something Went Wrong');
        }
      }
    });
  }

  void _imagePicker() {
    _pickImageAndUpload(context);
  }

  String amountInwords = '';
  int amount = 0;
  String amountTo = '';
  bool printDuplicate = false;

  void _addVoucher() async {
    setState(() {
      _defaultLoading = true;
      uuid = Uuid().v1();
      int? qty = int.tryParse(_productsServicePriceController.text);
      amount = qty!;
      amountInwords = _amountInWords;
      amountTo = _toTextController.text;
    });
    final parsedDate = DateFormat('dd-MMM-yyyy').parse(selectedDate);
    Timestamp timestamp = Timestamp.fromDate(parsedDate);
    await FirebaseFirestore.instance.collection('voucher').doc(uuid).set({
      'voucherPrintNo': tax_invoice_num,
      'date': timestamp,
      'amount': amount,
      'amountInWords': amountInwords.toUpperCase(),
      'voucherTo': amountTo,
      'voucherNO': voucherNO,
      'documentUrl': imageUrl.isEmpty ?'N/A':imageUrl,
      'beingTowards': reason,
      'fromUUID': SalesBilling.billFromCompanyUUID,
      'modeOfPayment': selectedPaymentValue,
      'voucherUUID': uuid,
    });
    _UploadedData();
  }

  Future<void> _addVoucherImageUpload() async {
    await FirebaseFirestore.instance.collection('voucher').doc(uuid).update({
      'documentUrl': imageUrl.isEmpty ?'N/A':imageUrl,
    });
    setState(() {
      _defaultLoading = false;
    });
    _refresh();
  }

// this function for change amount number in words//
  String _amountInWords = '';
  Future<void> _UploadedData() async {
    setState(() {
      _defaultLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('voucher')
        .where('voucherUUID', isEqualTo: uuid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.exists) {
          print(documentSnapshot['voucherPrintNo']);
          print(documentSnapshot['voucherPrintNo']);
          print(documentSnapshot['voucherNO']);
          setState(() {
            VoucherEnter.voucherNoGenerated =
                documentSnapshot['voucherPrintNo'];
          });
        } else {
          print('Something Went Wrong');
        }
      }
    });
  }

  void _updateAmountInWords() {
    String text = _productsServicePriceController.text;
    if (text.isEmpty) {
      setState(() {
        _amountInWords = '';
      });
    } else {
      try {
        int amount = int.parse(text);
        String words = NumberToWordsEnglish.convert(amount);
        setState(() {
          _amountInWords = words.toUpperCase() + ' only'.toUpperCase();
        });
      } catch (e) {
        setState(() {
          _amountInWords = 'Invalid amount';
        });
      }
    }
  }
  // end Here/

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String Date = DateFormat('dd-MMM-yyyy').format(now);
    // creating pfg page code start here//

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
                                  VoucherEnter.voucherNoGenerated,
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
                                  selectedDate.toString(),
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
                                  selectedPaymentValue,
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
                                  'Rs.${_productsServicePriceController.text.toString()}/-',
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
                                  _amountInWords.toUpperCase().toString(),
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
                                  _toTextController.text.toString(),
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
                                  _reasonTextController.text.toString(),
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
                                  VoucherEnter.voucherNoGenerated,
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
                                  selectedDate.toString(),
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
                                  selectedPaymentValue,
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
                                  'Rs.${_productsServicePriceController.text.toString()}/-',
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
                                  _amountInWords.toUpperCase().toString(),
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
                                  _toTextController.text.toString(),
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
                                  _reasonTextController.text.toString(),
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
                                    VoucherEnter.voucherNoGenerated,
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
                                    selectedDate.toString(),
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
                                    selectedPaymentValue,
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
                                    'Rs.${_productsServicePriceController.text.toString()}/-',
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
                                    _amountInWords.toUpperCase().toString(),
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
                                    _toTextController.text.toString(),
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
                                    _reasonTextController.text.toString(),
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

    // Future<void> _selectDate(BuildContext context) async {
    //   DatePicker.showDatePicker(
    //     context,
    //     showTitleActions: true,
    //     minTime: DateTime(2023),
    //     maxTime: DateTime.now(),
    //     onChanged: (date) {
    //       setState(() {
    //         selectedDate = date;
    //       });
    //     },
    //   );
    // }
    // end here//
    return _defaultLoading
        ? DefaultLoading()
        : Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () => _pickImageAndUpload(context),
              backgroundColor: Colors.green,
              child: const Icon(Icons.add_a_photo),
            ),
            body: SingleChildScrollView(
              child: Padding(
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
                                  'Add Voucher',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ))),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                            SizedBox(width: 10),
                            cDivider,
                            Text(
                              'Date:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10),
                            DropdownButton<String>(
                              value: selectedDate.substring(0, 2),
                              onChanged: isEditing
                                  ? (value) {
                                      setState(() {
                                        selectedDate =
                                            value! + selectedDate.substring(2);
                                      });
                                    }
                                  : null,
                              items: days
                                  .map<DropdownMenuItem<String>>((String day) {
                                return DropdownMenuItem<String>(
                                  value: day,
                                  child: Text(day),
                                );
                              }).toList(),
                            ),
                            SizedBox(width: 10),
                            DropdownButton<Map<String, String>>(
                              value: months.firstWhere((month) =>
                                  month['name'] ==
                                  selectedDate.substring(3, 6)),
                              onChanged: isEditing
                                  ? (value) {
                                      setState(() {
                                        selectedDate =
                                            selectedDate.replaceRange(
                                                3, 6, value!['name']!);
                                      });
                                    }
                                  : null,
                              items: months
                                  .map<DropdownMenuItem<Map<String, String>>>(
                                      (Map<String, String> month) {
                                return DropdownMenuItem<Map<String, String>>(
                                  value: month,
                                  child: Text(month['name']!),
                                );
                              }).toList(),
                            ),
                            SizedBox(width: 10),
                            DropdownButton<String>(
                              value: selectedDate.substring(7),
                              onChanged: isEditing
                                  ? (value) {
                                      setState(() {
                                        selectedDate =
                                            selectedDate.substring(0, 7) +
                                                value!;
                                      });
                                    }
                                  : null,
                              items: years
                                  .map<DropdownMenuItem<String>>((String year) {
                                return DropdownMenuItem<String>(
                                  value: year,
                                  child: Text(year),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        Flexible(
                            child: IconButton(
                                onPressed: () {
                                  _generatePdf();
                                }, icon: Icon(Icons.print)))
                      ],
                    ),
                    Divider(
                      height: 10,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From*',
                                style: TextStyle(fontSize: 10),
                              ),
                              DropdownButton(
                                value: _selectedValue,
                                items: _dropdownTaxBillFrom,
                                elevation: 10,
                                style: TextStyle(fontSize: 12),
                                onChanged: (Object? value) {},
                              ),
                            ],
                          ),
                        ),
                        cDivider,
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To*',
                                style: TextStyle(fontSize: 10),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: TextField(
                                      readOnly: !isEditing,
                                      controller: _toTextController,
                                      decoration: InputDecoration(
                                        labelText: 'Enter the name',
                                        border: OutlineInputBorder(),
                                      ),
                                      style: TextStyle(fontSize: 10.0),
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.done,
                                      maxLength: 1000,
                                    ),
                                  ),

                                  // Flexible(
                                  //   child: TextField(
                                  //     controller: _dateController,
                                  //     onChanged: (value) {
                                  //       setState(() {
                                  //         enteredDate = value;
                                  //       });
                                  //     },
                                  //   ),
                                  // ),
                                  // Center(
                                  //   child: DropdownButton<String>(
                                  //     hint: const Text('Select Company*',
                                  //         style: TextStyle(fontSize: 12)),
                                  //     value: SalesBilling
                                  //         .dropdownValueTaxBillToCompany,
                                  //     style: TextStyle(fontSize: 12),
                                  //     onChanged: (String? newValue) {
                                  //       setState(() {
                                  //         SalesBilling
                                  //                 .dropdownValueTaxBillToCompany =
                                  //             newValue;
                                  //       });
                                  //       _fetchCompanyInfo();
                                  //     },
                                  //     items: SalesBilling.dropdownDataTaxBillTo
                                  //         .map((String value) {
                                  //       return DropdownMenuItem<String>(
                                  //         value: value,
                                  //         child: Text(value),
                                  //       );
                                  //     }).toList(),
                                  //   ),
                                  // ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // cDivider,
                        // Flexible(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Text(
                        //         'Voucher No',
                        //         style: TextStyle(fontSize: 10),
                        //       ),
                        //       Container(
                        //         height: 30,
                        //         width: 150,
                        //         decoration: BoxDecoration(
                        //           color: Colors.grey.shade100,
                        //           border: Border.all(color: Colors.black54),
                        //           borderRadius: BorderRadius.circular(12),
                        //         ),
                        //         child: Center(
                        //           child: Text(
                        //             tax_invoice_num,
                        //             style: TextStyle(
                        //                 fontSize: 12,
                        //                 fontWeight: FontWeight.bold),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(),
                      ],
                    ),
                    Divider(
                      height: 10,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: SizedBox(
                            height: 30,
                            child: TextField(
                              readOnly: !isEditing,
                              controller: _reasonTextController,
                              onChanged: (value) {
                                setState(() {
                                  reason = _reasonTextController.text;
                                });
                              },
                              style: TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                labelText: 'Being Towards*',
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: smartBlue, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                  //<-- SEE HERE
                                  borderSide:
                                      BorderSide(width: 1, color: smartBlue),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: SizedBox(
                            height: 30,
                            child: TextField(
                              readOnly: !isEditing,
                              controller: _productsServicePriceController,
                              onChanged: (value) {},
                              style: TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                labelText: 'Amount *',
                                prefixIcon: Icon(
                                  Icons.currency_rupee,
                                  size: 16,
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: smartBlue, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                  //<-- SEE HERE
                                  borderSide:
                                      BorderSide(width: 1, color: smartBlue),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: SizedBox(
                            height: 30,
                            child: TextField(
                              readOnly: true,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: '$_amountInWords',
                                prefixIcon: Icon(
                                  Icons.currency_rupee,
                                  size: 16,
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: smartBlue, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                  //<-- SEE HERE
                                  borderSide:
                                      BorderSide(width: 1, color: smartBlue),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Method of Payment',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedPaymentValue,
                            onChanged: isEditing
                                ? (newValue) {
                                    setState(() {
                                      selectedPaymentValue = newValue!;
                                    });
                                  }
                                : null,
                            items: paymentItems
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _submit
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 30,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      width: 2.0,
                                      color: smartBlue,
                                    )),
                                onPressed: () async {
                                  _generatePdf();
                                },
                                child: Text(
                                  'Re-Print Voucher',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: smartBlue,
                                      fontWeight: FontWeight.bold),
                                )),
                          )
                        : SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 30,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: smartBlue,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _submit = true;
                                  });
                                  if (_productsServicePriceController
                                          .text.isEmpty ||
                                      _reasonTextController.text.isEmpty ||
                                      _toTextController.text.isEmpty) {
                                    setState(() {
                                      _submit = false;
                                    });
                                    print('object');
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      backgroundColor: smartRed,
                                      behavior: SnackBarBehavior.floating,
                                      width: 300,
                                      action: SnackBarAction(
                                        label: 'Okay',
                                        disabledTextColor: Colors.white,
                                        textColor: Colors.yellow,
                                        onPressed: () {
                                          ScaffoldMessenger.of(context);
                                        },
                                      ),
                                      content: const Text(
                                          'Please enter missing fields '),
                                    ));
                                  } else {
                                    setState(() {
                                      _defaultLoading = true;
                                      isEditing = false;
                                    });
                                    tax_invoice_num =
                                        await generateSequenceNumber();
                                    _addVoucher();
                                    Future.delayed(Duration(seconds: 5), () {
                                      _generatePdf();
                                      setState(() {
                                        _defaultLoading = false;
                                      });
                                    });
                                  }
                                  // print(tax_invoice_num);
                                },
                                child: Text(
                                  'Submit / Print Voucher',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                    Divider(
                      height: 10,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _submit
                        ? Row(
                            children: [
                              Flexible(
                                flex: 5,
                                child: SizedBox(
                                  height: 30,
                                  child: TextField(
                                    controller: _fileNameController,
                                    style: TextStyle(fontSize: 12),
                                    decoration: InputDecoration(
                                      labelText:
                                          _fileNameController.text.isNotEmpty
                                              ? _fileNameController.text
                                              : 'Selected File to upload *',
                                      prefixIcon: Icon(
                                        Icons.file_copy,
                                        size: 16,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: smartBlue, width: 1)),
                                      focusedBorder: OutlineInputBorder(
                                        //<-- SEE HERE
                                        borderSide: BorderSide(
                                            width: 1, color: smartBlue),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 30,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: smartBlue),
                                        onPressed: () {
                                          _imagePicker();
                                          setState(() {
                                            _defaultLoading = false;
                                          });
                                        },
                                        child: Text(
                                          'Choose',
                                          style: TextStyle(fontSize: 12),
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
                    Divider(
                      height: 10,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _submit
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 30,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: smartBlue),
                                onPressed: () async {
                                  if (_fileNameController.text.isEmpty) {
                                    print('Hello');
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      backgroundColor: smartRed,
                                      behavior: SnackBarBehavior.floating,
                                      width: 300,
                                      action: SnackBarAction(
                                        label: 'Okay',
                                        disabledTextColor: Colors.white,
                                        textColor: Colors.yellow,
                                        onPressed: () {
                                          ScaffoldMessenger.of(context);
                                        },
                                      ),
                                      content:
                                          const Text('Please Upload Voucher'),
                                    ));
                                  } else {
                                    _addVoucherImageUpload();
                                    setState(() {
                                      _fileNameController.clear();
                                      _productsServicePriceController.clear();
                                      _toTextController.clear();
                                      _reasonTextController.clear();
                                      isEditing = true;
                                    });
                                    setState(() {
                                      _submit = false;
                                    });
                                  }
                                  // print(tax_invoice_num);
                                },
                                child: Text(
                                  'Upload Signed Voucher',
                                  style: TextStyle(fontSize: 12),
                                )),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ),
          );
  }
}

// incase of emergency use old code//
// _addNewCompany
//     ? Flexible(
//         child: Column(
//         children: [
//           SizedBox(
//             height: 30,
//             child: TextField(
//               controller: _companyNameController,
//               style: TextStyle(fontSize: 12),
//               decoration: InputDecoration(
//                 labelText: 'Seller Name*',
//                 prefixIcon: Icon(
//                   Icons.local_mall,
//                   size: 16,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: smartBlue, width: 1)),
//                 focusedBorder: OutlineInputBorder(
//                   //<-- SEE HERE
//                   borderSide: BorderSide(
//                       width: 1, color: smartBlue),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           SizedBox(
//             height: 30,
//             child: TextField(
//               controller: _addressController,
//               style: TextStyle(fontSize: 12),
//               decoration: InputDecoration(
//                 labelText: 'Address *',
//                 prefixIcon: Icon(
//                   Icons.local_mall,
//                   size: 16,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: smartBlue, width: 1)),
//                 focusedBorder: OutlineInputBorder(
//                   //<-- SEE HERE
//                   borderSide: BorderSide(
//                       width: 1, color: smartBlue),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           SizedBox(
//             height: 30,
//             child: TextField(
//               controller: _cityController,
//               style: TextStyle(fontSize: 12),
//               decoration: InputDecoration(
//                 labelText: 'City *',
//                 prefixIcon: Icon(
//                   Icons.local_mall,
//                   size: 16,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: smartBlue, width: 1)),
//                 focusedBorder: OutlineInputBorder(
//                   //<-- SEE HERE
//                   borderSide: BorderSide(
//                       width: 1, color: smartBlue),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           SizedBox(
//             height: 30,
//             child: TextField(
//               controller: _stateController,
//               style: TextStyle(fontSize: 12),
//               decoration: InputDecoration(
//                 labelText: 'State *',
//                 prefixIcon: Icon(
//                   Icons.local_mall,
//                   size: 16,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: smartBlue, width: 1)),
//                 focusedBorder: OutlineInputBorder(
//                   //<-- SEE HERE
//                   borderSide: BorderSide(
//                       width: 1, color: smartBlue),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           SizedBox(
//             height: 30,
//             child: TextField(
//               controller: _countryController,
//               style: TextStyle(fontSize: 12),
//               decoration: InputDecoration(
//                 labelText: 'Country *',
//                 prefixIcon: Icon(
//                   Icons.local_mall,
//                   size: 16,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: smartBlue, width: 1)),
//                 focusedBorder: OutlineInputBorder(
//                   //<-- SEE HERE
//                   borderSide: BorderSide(
//                       width: 1, color: smartBlue),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           SizedBox(
//             height: 30,
//             child: TextField(
//               controller: _pinCodeController,
//               style: TextStyle(fontSize: 12),
//               decoration: InputDecoration(
//                 labelText: 'Pin Code *',
//                 prefixIcon: Icon(
//                   Icons.local_mall,
//                   size: 16,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: smartBlue, width: 1)),
//                 focusedBorder: OutlineInputBorder(
//                   //<-- SEE HERE
//                   borderSide: BorderSide(
//                       width: 1, color: smartBlue),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           SizedBox(
//             height: 30,
//             child: TextField(
//               controller: _gstinController,
//               style: TextStyle(fontSize: 12),
//               decoration: InputDecoration(
//                 labelText: 'GSTIN *',
//                 prefixIcon: Icon(
//                   Icons.local_mall,
//                   size: 16,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: smartBlue, width: 1)),
//                 focusedBorder: OutlineInputBorder(
//                   //<-- SEE HERE
//                   borderSide: BorderSide(
//                       width: 1, color: smartBlue),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Row(
//             children: [
//               Flexible(
//                 child: SizedBox(
//                   width:
//                       MediaQuery.of(context).size.width,
//                   height: 30,
//                   child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           side: BorderSide(
//                             width: 1.0,
//                             color: smartBlue,
//                           )),
//                       onPressed: () {
//                         setState(() {
//                           _addNewCompany = false;
//                         });
//                       },
//                       child: Text(
//                         'Cancel',
//                         style: TextStyle(
//                             fontSize: 12,
//                             color: smartBlue),
//                       )),
//                 ),
//               ),
//               SizedBox(
//                 width: 5,
//               ),
//               Flexible(
//                 child: SizedBox(
//                   width:
//                       MediaQuery.of(context).size.width,
//                   height: 30,
//                   child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: smartBlue),
//                       onPressed: () {
//                         setState(() {
//                           _addNewCompany = false;
//                           _defaultLoading = true;
//                         });
//                         _converTextController();
//                       },
//                       child: Text(
//                         'Add',
//                         style: TextStyle(fontSize: 12),
//                       )),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ))
//:
// incase of emergency use old code//

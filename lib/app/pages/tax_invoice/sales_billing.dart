import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:sandhut/widgets/default_loading.dart';
import '../../../widgets/constrans.dart';
import 'package:pdf/widgets.dart' as pw;

class SalesBilling extends StatefulWidget {
  const SalesBilling({super.key});
  static String cgst = '';
  static String sgst = '';
  static String gstin = '';
  static String igst = '';

  //bill to Company Data
  static String billToCompanyName = '';
  static List<dynamic> Address = [];
  static String billToCompanyTaxNo = '';
  static String billToCompanyGstinNo = '';
  static String billToCompanyPhoneNo = '';
  static String billToCompanyEmailId = '';
  static String billToCompanyWebsite = '';
  static String billToCompanyBankName = '';
  static String billToCompanyBankAccountNo = '';
  static String billToCompanyBankIfseCode = '';
  static String billToCompanyBankBranch = '';
  static String billToCompanyNickName = '';
  static String billToCompanyUUID = '';
  static List<String> dropdownDataTaxBillTo = [];
  static String? dropdownValueTaxBillToCompany;
  //bill to Company Data

  //bill From Company Data
  static String billFromCompanyName = '';
  static List<dynamic> billFromCompanyAddress = [];
  static String billFromCompanyTaxNo = '';
  static String billFromCompanyGstinNo = '';
  static String billFromCompanyPhoneNo = '';
  static String billFromCompanyEmailId = '';
  static String billFromCompanyWebsite = '';
  static List<dynamic> billFromCompanyBankinfo = [];
  static String billFromCompanyBankName = '';
  static String billFromCompanyBankAccountNo = '';
  static String billFromCompanyBankIfseCode = '';
  static String billFromCompanyBankBranch = '';
  static String billFromCompanyNickName = '';
  static String billFromCompanyUUID = '';
  //bill From Company Data

  @override
  State<SalesBilling> createState() => _SalesBillingState();
}

class _SalesBillingState extends State<SalesBilling> {
  GlobalKey dropdownButtonKey = GlobalKey();
  DateTime today = DateTime.now();
  bool _defaultLoading = false;

// Tax Type
  List<List<String>> _dropdownDataTaxTaxType = [];
  String? _dropdownValueTaxBillTaxType;
  int taxNill = 0;
  int taxCGST = 9;
  int taxSGST = 9;
  int taxIGST = 18;
  int taxGSTIN = 18;
  bool CSGST = true;
  bool IGST = false;
  bool GSTIN = false;
// Tax Type

  @override
  void initState() {
    super.initState();
    fetchBillingToCompany();
    fetchTexType();
    _taxBillFrom();
    _taxBillto();
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

  TextEditingController _textEditingControllerCGST = TextEditingController();
  TextEditingController _textEditingControllerSGST = TextEditingController();
  TextEditingController _textEditingControllerIGST = TextEditingController();
  TextEditingController _textEditingControllerGSTIN = TextEditingController();

  void fetchTexType() async {
    setState(() {
      _defaultLoading = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('invoice_data')
        .doc('VsElRi4N5p5ds1e0Lzt2')
        .collection('tax_types')
        .where('status', isEqualTo: 'active')
        .get();
    setState(() {
      _dropdownDataTaxTaxType = querySnapshot.docs
          .map((doc) => (doc.get('types') as List<dynamic>)
              .map((item) => item.toString())
              .toList())
          .toList();
      if (_dropdownDataTaxTaxType.isNotEmpty &&
          _dropdownDataTaxTaxType[0].isNotEmpty) {
        _dropdownValueTaxBillTaxType = _dropdownDataTaxTaxType[0][0];
        taxValues();
      } // Select the first value from the first array
    });
    setState(() {
      _defaultLoading = false;
    });
  }

  void taxValues() async {
    if (_dropdownValueTaxBillTaxType.toString() == 'CGST + SGST') {
      print('CGST + IGST ');
      setState(() {
        CSGST = true;
        IGST = false;
        GSTIN = false;
        _textEditingControllerCGST.text = 9.toString();
        _textEditingControllerSGST.text = 9.toString();
      });
    } else if (_dropdownValueTaxBillTaxType.toString() == 'IGST') {
      print('IGST');
      setState(() {
        _textEditingControllerIGST.text = 18.toString(); //string
        CSGST = false;
        IGST = true;
        GSTIN = false;
        SalesBilling.igst = _textEditingControllerIGST.text;
      });
    } else if (_dropdownValueTaxBillTaxType.toString() == 'GSTIN') {
      print('GSTIN');
      setState(() {
        _textEditingControllerGSTIN.text = 18.toString(); //string
        CSGST = false;
        IGST = false;
        GSTIN = true;
        SalesBilling.gstin = _textEditingControllerGSTIN.text;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _billCompany = 'SANDHUT INDIA PRIVATE LIMITED';
  String _selectedValue = "";

  _taxBillFrom() async {
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

  _taxBillto() async {
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

  List<DropdownMenuItem<String>> get _dropdownTaxBillFrom {
    List<DropdownMenuItem<String>> fromBillData = [
      DropdownMenuItem(
          child: Text(SalesBilling.billFromCompanyName),
          value: SalesBilling.billFromCompanyName),
    ];
    return fromBillData;
  }
  bool mobile = false;

  @override
  Widget build(BuildContext context) {
    // creating pfg page code start here//
    Future<void> _generatePdf() async {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text("Hello World",style: pw.TextStyle(fontSize: 20)),
            ); // Center
          }));
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    }
    // end here//


    final mobile = MediaQuery.of(context).size.width > 900 ? false : true;

    return _defaultLoading
        ? DefaultLoading()
        : Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: smartBlue,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withOpacity(.60),
              selectedFontSize: 14,
              unselectedFontSize: 14,
              onTap: (value) {
                // Respond to item press.
              },
              items: [
                BottomNavigationBarItem(
                  label: 'Icon',
                  icon:
                      IconButton(onPressed: () {}, icon: Icon(Icons.favorite)),
                ),
                BottomNavigationBarItem(
                  label: 'Pdf',
                  icon: IconButton(
                      onPressed: _generatePdf,
                      icon: Icon(Icons.picture_as_pdf)),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tax invoice From*',
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
                            cDivider,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tax invoice to*',
                                  style: TextStyle(fontSize: 10),
                                ),
                                Row(
                                  children: [
                                    Center(
                                      child: DropdownButton<String>(
                                        hint: const Text('Select Company*',
                                            style: TextStyle(fontSize: 12)),
                                        value: SalesBilling
                                            .dropdownValueTaxBillToCompany,
                                        style: TextStyle(fontSize: 12),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            SalesBilling
                                                    .dropdownValueTaxBillToCompany =
                                                newValue;
                                          });
                                        },
                                        items: SalesBilling
                                            .dropdownDataTaxBillTo
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    SizedBox(
                                      width: 60,
                                      height: 30,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: smartBlue),
                                          onPressed: () {},
                                          child: Text(
                                            'New',
                                            style: TextStyle(fontSize: 12),
                                          )),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            cDivider,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tax Type*',
                                  style: TextStyle(fontSize: 10),
                                ),
                                Center(
                                  child: DropdownButton<String>(
                                    hint: const Text('Select Tax Type*',
                                        style: TextStyle(fontSize: 12)),
                                    value: _dropdownValueTaxBillTaxType,
                                    style: TextStyle(fontSize: 12),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _dropdownValueTaxBillTaxType = newValue;
                                        taxValues();
                                      });
                                    },
                                    items:
                                        _dropdownDataTaxTaxType.expand((array) {
                                      return array.map((value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      });
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            cDivider,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tax %*',
                                  style: TextStyle(fontSize: 10),
                                ),
                                CSGST
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.grey.shade400)),
                                        height: 25,
                                        width: 80,
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                _textEditingControllerCGST
                                                    .text = value;
                                              });
                                            },
                                            controller:
                                                _textEditingControllerCGST,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                suffixText: '%CGST',
                                                suffixStyle:
                                                    TextStyle(fontSize: 10)),
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ))
                                    : SizedBox(),
                                SizedBox(
                                  height: 5,
                                ),
                                CSGST
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.grey.shade400)),
                                        height: 25,
                                        width: 80,
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                _textEditingControllerSGST
                                                    .text = value;
                                              });
                                            },
                                            controller:
                                                _textEditingControllerSGST,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                suffixText: '%SGST',
                                                suffixStyle:
                                                    TextStyle(fontSize: 10)),
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ))
                                    : SizedBox(),
                                IGST
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.grey.shade400)),
                                        height: 25,
                                        width: 80,
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                SalesBilling.gstin =
                                                    _textEditingControllerIGST
                                                        .text;
                                              });
                                            },
                                            controller:
                                                _textEditingControllerIGST,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                suffixText: '%IGST',
                                                suffixStyle:
                                                    TextStyle(fontSize: 10)),
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ))
                                    : GSTIN
                                        ? Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade400)),
                                            height: 25,
                                            width: 80,
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: TextField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    SalesBilling.gstin =
                                                        _textEditingControllerGSTIN
                                                            .text;
                                                  });
                                                },
                                                controller:
                                                    _textEditingControllerGSTIN,
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    suffixText: '%GSTIN',
                                                    suffixStyle: TextStyle(
                                                        fontSize: 10)),
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ))
                                        : SizedBox(),
                              ],
                            ),
                            cDivider,
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //Flexible(child: child),
                            Text(
                              'Search Products',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.grey.shade400)),
                                height: 25,
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: TextField(
                                    controller: _textEditingControllerGSTIN,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        suffixText: '%GSTIN',
                                        suffixStyle: TextStyle(fontSize: 10)),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                )),
                            SizedBox(
                              width: 60,
                              height: 20,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: smartBlue),
                                  onPressed: () {},
                                  child: Text(
                                    'Add',
                                    style: TextStyle(fontSize: 12),
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SL. No.',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Text(
                              'Description of Goods/Services',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Text(
                              'HSN/SAC',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Text(
                              'Quantity',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Text(
                              'Rate',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Text(
                              'Amount ',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Text(
                              'Action ',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '01',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Digital Marketing',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Social Media Marketing, Zomato Marketing ',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                            Text(
                              '45688',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '5',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '500',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '₹2,500 ',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            Icon(
                              Icons.close,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ),

                    //       TextButton (
                    //   child: Text('Click to Pdf',
                    //     style: TextStyle(
                    //       fontWeight: FontWeight.w600,
                    //       fontSize: 18.0,
                    //     ),
                    //   ),
                    //   onPressed: _generatePdf,
                    // ),

                    // FloatingActionButton(onPressed:(){
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => const TaxInvoicePDF()),
                    //   );
                    //
                    // },icon: Icon(Icons.picture_as_pdf))
                  ],
                ),
              ),
            ),
          );
  }
}

// use this code for bottomNavigationbar item icon:pdf//

//   int bill = 0;
//   int tax = 0;
//   int text = 0;
//   setState(() {
//      bill = int.parse(_textEditingControllerCGST.text);
//      tax = int.parse(_textEditingControllerSGST.text);
//      text = bill+tax;
//      SalesBilling.cgst= text.toString();
//      SalesBilling.sgst= text.toString();
//
//
//   });
//   print(bill);
//   print(tax);
//   print(SalesBilling.igst);
//   Navigator.push(
//     context,
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           appBar: AppBar(
//             title: Text('Hello'),
//           ),
//           body: Center(
//             child: ElevatedButton(
//               onPressed: _generatePdf,
//               child: Text('Click Me'),
//             ),
//           ),
//         ),
//       )
//   );
// },  icon: Icon(Icons.picture_as_pdf))
// end here//

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';



class ExpensePage extends StatefulWidget {
  static String SellerAddress = "";
  static String SellerDistrict = "";
  static String BuyerAddress = "";
  static String BuyerDistrict = "";
  static String Invoice_num = "";


  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  bool _defaultLoading = false;

  static List<String> _dropdownDataTaxBillTo = [];
  static String? _dropdownValueTaxBillToCompany ;

  @override

  void fetchBillingToCompany() async {
    setState(() {
      _defaultLoading = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('company_info')
        .where('status', isEqualTo: 'active')
        .get();
    setState(() {
      _dropdownDataTaxBillTo = querySnapshot.docs
          .map((doc) => doc.get('legal_name').toString())
          .toList();
    });
    setState(() {
      _defaultLoading = false;
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    fetchBillingToCompany();
    Seller();
    Buyer();

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

  Seller() async {
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
          ExpensePage.SellerAddress =doc['legal_address'][0].toString();

        });
      }
    });
  }
  Buyer() async {
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
          ExpensePage.BuyerAddress =doc['legal_address'][0].toString();

        });
      }
    });
  }

  Future<void> uploadFileToFirestore() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        PlatformFile file = result.files.first;

        // Create a reference to the Firebase Cloud Storage bucket
        firebase_storage.Reference storageRef =
        firebase_storage.FirebaseStorage.instance.ref().child(file.name);

        // Upload the file to Firebase Cloud Storage
        await storageRef.putFile(File(file.path!));

        // Get the download URL of the uploaded file
        String downloadURL = await storageRef.getDownloadURL();

        // Save the download URL to Firestore (you can save it to a specific collection and document)
        await FirebaseFirestore.instance
            .collection('files')
            .doc(
            'document_id') // Replace 'document_id' with the specific document where you want to store the download URL
            .set({'fileURL': downloadURL});

        print('File uploaded and URL saved successfully.');
      } else {
        // User canceled the file picking
        print('File picking canceled.');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 100,
                    height: 23,
                    alignment: Alignment.center,
                    child: Text('Product',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: Text(actualDate),
                  ),
                )
              ],
            ),Divider(),
            SizedBox(height: 30,),
            Center(
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 23,
                        child: Text(
                          'BUYER',
                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          width: 400,
                          height: 175,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              '${ExpensePage.SellerAddress}\nKarnataka\nIndia\n562130',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 23,
                        child: Text(
                          'SELLER',
                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          width: 400,
                          height: 175,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(8)),
                          child:Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButton<String>(
                                  hint: const Text('Select Company*',style: TextStyle(fontSize: 12)),
                                  value: _dropdownValueTaxBillToCompany,
                                  style: TextStyle(fontSize: 12),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _dropdownValueTaxBillToCompany = newValue;
                                    });
                                  },
                                  items: _dropdownDataTaxBillTo.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 5,),

                            ],
                          ),

                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),Divider(),
            SizedBox(height: 20,),
            Row(
              children: [
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 100,
                      height: 23,
                      alignment: Alignment.center,
                      child: Text('Total Amount',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    ),
                  ),

                ],),
              ],
            ),
            Row(
              children: [
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: 200,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(8)),
                      alignment: Alignment.center,
                      child: Text('15,621'),
                    ),
                  ),

                ],),
              ],
            ),Divider(),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: uploadFileToFirestore,
                  child: Text('Select File'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                  ),
                ),SizedBox(width: 7,),
                ElevatedButton(
                  onPressed: (){},
                  child: Text('Upload'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                  ),
                ),
                SizedBox(width: 10,),


              ],
            )
          ],
        ));
  }
}


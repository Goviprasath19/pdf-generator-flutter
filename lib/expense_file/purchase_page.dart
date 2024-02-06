import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';




class PurchasePage extends StatefulWidget {
  static String SellerAddress = "";
  static String SellerDistrict = "";
  static String BuyerAddress = "";
  static String BuyerDistrict = "";
  static String Invoice_num = "";

  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {

  void initState() {
    // TODO: implement initState
    super.initState();
    Seller();
    Buyer();

    date();
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
          PurchasePage.SellerAddress =doc['legal_address'][0].toString();

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
          PurchasePage.BuyerAddress =doc['legal_address'][0].toString();

        });
      }
    });
  }
  String actualDate = '';
  date() {
    setState(() {
      var now = DateTime.now();
      var currentDate = DateFormat('dd/MM/yyyy');
      actualDate = currentDate.format(now);
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
  Future<XFile?> takePictureFromCamera() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
    print('${file?.path}');
    return file;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Container(
                width: 100,
                height: 23,
                alignment: Alignment.center,
                child: Text('Date',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              )
            ],
          ),
          Row(
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            '${PurchasePage.SellerAddress}\nKarnataka\nIndia\n562130',
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
                            '${PurchasePage.SellerAddress}\nKarnataka\nIndia\n562130',
                            style: TextStyle(fontSize: 16),
                          ),
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

              GestureDetector(
                onTap: () async {
                  XFile? file = await takePictureFromCamera();
                  // Do something with the image file, if needed.
                  // For example, you can display the image using `Image.file(file)`
                },
                child: Icon(Icons.camera_alt_outlined), // Replace this Icon with your desired icon
              ),

            ],
          )
        ],
      ),

    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../widgets/constrans.dart';
import '../../../widgets/default_loading.dart';
import 'dart:html' as html;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../tax_invoice/sales_billing.dart';

class PurchaseEnter extends StatefulWidget {
  const PurchaseEnter({super.key});

  @override
  State<PurchaseEnter> createState() => _PurchaseEnterState();
}

class _PurchaseEnterState extends State<PurchaseEnter> {
  var uuid = '';
  String imageUrl = '';
  bool _defaultLoading = true;
  String _selectedValue = "";
  String _billCompany = 'SANDHUT INDIA PRIVATE LIMITED';
  bool _addNewCompany = false;
  TextEditingController _fileNameController = TextEditingController();
  TextEditingController _companyNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _pinCodeController = TextEditingController();
  TextEditingController _gstinController = TextEditingController();
  TextEditingController _productsServicePriceController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emaileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loading_();
    fetchBillingToCompany();
    _expenseTO();
    _sellerInfo();
    fetchCategoriesType();
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
          .child('/documents/purchase/purchase-$fileName.jpg');

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

  String _sellerCompanyUUID = '';
  Future<void> _fetchCompanyInfo() async {
    await FirebaseFirestore.instance
        .collection('company_info')
        .where('legal_name',
            isEqualTo: SalesBilling.dropdownValueTaxBillToCompany)
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

  List<String> _legalAddress = [];
  void _converTextController() {
    String address = _addressController.text;
    String city = _cityController.text;
    String state = _stateController.text;
    String country = _countryController.text;
    String pinCode = _pinCodeController.text;
    _legalAddress = [address, city, state, country, pinCode];
    _addCompany();
  }

  _addCompany() async {
    setState(() {
      uuid = Uuid().v1();
    });
    await FirebaseFirestore.instance.collection('company_info').doc(uuid).set({
      'cin_no': 'N/A',
      'company_id': 'N/A',
      'email': _emaileController.text.isEmpty ? 'N/A' : _emaileController.text,
      'gstin_no': _gstinController.text.isEmpty ? 'N/A' : _gstinController.text,
      'legal_address': _legalAddress,
      'legal_name': _companyNameController.text,
      'nick_name': _companyNameController.text,
      'pan': 'N/A',
      'status': 'active',
      'phone_no': _phoneController.text,
      'tax_no': _gstinController.text.isEmpty ? 'N/A' : _gstinController.text,
      'uuid': uuid,
      'company_no': '00',
    });
    setState(() {
      _defaultLoading = false;
    });
    _refresh();
  }
  List<List<String>> _dropdownDataTaxTaxType = [];
  String? _dropdownValueCategory;

  void fetchCategoriesType() async {
    setState(() {
      _defaultLoading = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expenses_categories')
        .where('status', isEqualTo: 'active')
        .get();
    setState(() {
      _dropdownDataTaxTaxType = querySnapshot.docs
          .map((doc) => (doc.get('category') as List<dynamic>)
          .map((item) => item.toString())
          .toList())
          .toList();
      if (_dropdownDataTaxTaxType.isNotEmpty &&
          _dropdownDataTaxTaxType[0].isNotEmpty) {
        _dropdownValueCategory = _dropdownDataTaxTaxType[0][0];
      } // Select the first value from the first array
    });
    print(_dropdownValueCategory);
    setState(() {
      _defaultLoading = false;
    });
  }

  _addPurchase() async {
    setState(() {
      uuid = Uuid().v1();
    });
    await FirebaseFirestore.instance.collection('purchase').doc(uuid).set({
      'sellerCompanyUUID': _sellerCompanyUUID, //from company_info table
      'purchaseCompanyUUID': SalesBilling.billFromCompanyUUID, // sandhut table
      'date': DateTime.now(),
      'imgUrl': imageUrl,
      'category':_dropdownValueCategory,
      'products/services': _productsServicePriceController.text,
      'purchaseUUID': uuid,
    });
    setState(() {
      _defaultLoading = false;
    });
    _refresh();
  }
  bool mobile = false;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width > 900 ? false : true;
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
                                child: const Text(
                                  'Add Purchase',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ))),
                        Flexible(
                            child: IconButton(
                                onPressed: () {}, icon: Icon(Icons.print)))
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
                                'Buyer*',
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
                                'Seller*',
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
                                        _fetchCompanyInfo();
                                      },
                                      items: SalesBilling.dropdownDataTaxBillTo
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
                                        onPressed: () {
                                          setState(() {
                                            _addNewCompany = !_addNewCompany;
                                          });
                                        },
                                        child: Text(
                                          'New',
                                          style: TextStyle(fontSize: 12),
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        cDivider,
                        _addNewCompany?SizedBox():
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Category*',
                                style: TextStyle(fontSize: 10),
                              ),
                              Row(
                                children: [
                                  Center(
                                    child: DropdownButton<String>(
                                      hint: const Text('Select Category*',
                                          style: TextStyle(fontSize: 12)),
                                      value:_dropdownValueCategory,
                                      style: TextStyle(fontSize: 12),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _dropdownValueCategory =
                                              newValue;
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
                            ],
                          ),
                        ),
                        _addNewCompany
                            ? Flexible(
                                child: Column(
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: TextField(
                                      controller: _companyNameController,
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'Seller Name*',
                                        prefixIcon: Icon(
                                          Icons.local_mall,
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: TextField(
                                      controller: _addressController,
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'Address *',
                                        prefixIcon: Icon(
                                          Icons.local_mall,
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: TextField(
                                      controller: _cityController,
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'City *',
                                        prefixIcon: Icon(
                                          Icons.local_mall,
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: TextField(
                                      controller: _stateController,
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'State *',
                                        prefixIcon: Icon(
                                          Icons.local_mall,
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: TextField(
                                      controller: _countryController,
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'Country *',
                                        prefixIcon: Icon(
                                          Icons.local_mall,
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: TextField(
                                      controller: _pinCodeController,
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'Pin Code *',
                                        prefixIcon: Icon(
                                          Icons.local_mall,
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: TextField(
                                      controller: _phoneController,
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'Phone No. *',
                                        prefixIcon: Icon(
                                          Icons.phone,
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: TextField(
                                      controller: _gstinController,
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: 'GSTIN *',
                                        prefixIcon: Icon(
                                          Icons.local_mall,
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 30,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  side: BorderSide(
                                                    width: 1.0,
                                                    color: smartRed,
                                                  )),
                                              onPressed: () {
                                                setState(() {
                                                  _addNewCompany = false;
                                                  _gstinController.clear();
                                                  _productsServicePriceController.clear();
                                                  _phoneController.clear();
                                                  _pinCodeController.clear();
                                                  _stateController.clear();
                                                  _countryController.clear();
                                                  _cityController.clear();
                                                  _companyNameController.clear();
                                                });
                                              },
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: smartRed),
                                              )),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Flexible(
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 30,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: smartBlue),
                                              onPressed: () {
                                                setState(() {
                                                  _addNewCompany = false;
                                                  _defaultLoading = true;
                                                });
                                                if(_companyNameController.text.isEmpty || _addressController.text.isEmpty || _cityController.text.isEmpty||_countryController.text.isEmpty ||_stateController.text.isEmpty||_pinCodeController.text.isEmpty || _phoneController.text.isEmpty || _gstinController.text.isEmpty){
                                                  print('object');
                                                  setState(() {
                                                    _addNewCompany = true;
                                                    _defaultLoading = false;
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        backgroundColor: smartRed,
                                                        behavior: SnackBarBehavior.floating,
                                                        width: 300,
                                                        action: SnackBarAction(
                                                          label: 'Okay',
                                                          disabledTextColor: Colors.white,
                                                          textColor: Colors.yellow, onPressed: () {
                                                          ScaffoldMessenger.of(context);
                                                        },
                                                        ),
                                                        content: Text('Please enter missing fields '),
                                                      )
                                                  );
                                                }else{
                                                  _converTextController();
                                                }
                                              },
                                              child: Text(
                                                'Add',
                                                style: TextStyle(fontSize: 12),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ))
                            : SizedBox(),
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
                          flex: 5,
                          child: SizedBox(
                            height: 30,
                            child: TextField(
                              controller: _fileNameController,
                              style: TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                labelText: _fileNameController.text.isNotEmpty
                                    ? _fileNameController.text
                                    : 'Selected File to upload *',
                                prefixIcon: Icon(
                                  Icons.file_copy,
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
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                              controller: _productsServicePriceController,
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
                        )
                      ],
                    ),
                    Divider(
                      height: 10,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 30,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: smartBlue),
                          onPressed: () async {
                            if(_fileNameController.text.isEmpty || _productsServicePriceController.text.isEmpty || _dropdownValueCategory!.isEmpty || SalesBilling.dropdownDataTaxBillTo.isEmpty){
                              print('object');
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: smartRed,
                                    behavior: SnackBarBehavior.floating,
                                    width: 300,
                                    action: SnackBarAction(
                                      label: 'Okay',
                                      disabledTextColor: Colors.white,
                                      textColor: Colors.yellow, onPressed: () {
                                      ScaffoldMessenger.of(context);
                                    },
                                    ),
                                    content: Text('Please enter missing fields '),
                                  )
                              );
                            }else{
                              _addPurchase();
                              setState(() {
                                _fileNameController.clear();
                                _productsServicePriceController.clear();
                              });
                            }
                            // tax_invoice_num = await generateSequenceNumber();
                            // print(tax_invoice_num);
                          },
                          child: Text(
                            'Submit',
                            style: TextStyle(fontSize: 12),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

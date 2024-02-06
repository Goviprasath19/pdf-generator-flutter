import 'dart:async';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../widgets/constrans.dart';




class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  DateTime today = DateTime.now();
  String _billFromCompanyName = '';
  List<dynamic> _billFromCompanyAddress = [];
  String _billFromCompanyTaxNo = '';
  String _billFromCompanyGstinNo = '';
  String _billFromCompanyPhoneNo = '';
  String _billFromCompanyEmailId = '';
  String _billFromCompanyWebsite = '';
  List<dynamic> _billFromCompanyBankinfo = [];
  String _billFromCompanyBankName = '';
  String _billFromCompanyBankAccountNo = '';
  String _billFromCompanyBankIfseCode = '';
  String _billFromCompanyBankBranch = '';
  String _billFromCompanyNickName = '';
  String _billFromCompanyUUID = '';

  @override
  void initState() {
    _billFrom();
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  String _billCompany = 'SANDHUT INDIA PRIVATE LIMITED';
  _billFrom() async {
    await FirebaseFirestore.instance
        .collection('snadhut')
        .where('legal_name', isEqualTo: _billCompany)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if(documentSnapshot.exists){
          setState(() {
            _billFromCompanyUUID = documentSnapshot.id;
            _billFromCompanyName = documentSnapshot['legal_name'];
            _billFromCompanyAddress = documentSnapshot['legal_address'];
             _billFromCompanyTaxNo = documentSnapshot['tax_no'] =='' ? 'No Data':documentSnapshot['tax_no'];
            _billFromCompanyGstinNo = documentSnapshot['gstin_no'] =='' ? 'No Data':documentSnapshot['gstin_no'];
           _billFromCompanyPhoneNo = documentSnapshot['phone_no'].toString();
           _billFromCompanyEmailId = documentSnapshot['email'];
            _billFromCompanyWebsite = documentSnapshot['company_website'];
             _billFromCompanyBankinfo = documentSnapshot['bank'];
            _billFromCompanyNickName = documentSnapshot['nick_name'];
          });
        }else{
          print('Something Went Wrong');
        }
      }
    });
  }
  bool mobile = false;

  
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width > 900 ? false : true;
    return Scaffold(

      body: SingleChildScrollView(
          child: Column(
            children: [
            ],
          ),
        ),
    );

  }
}

import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:sandhut/app/pages/expense/expense_enter.dart';
import 'package:sandhut/expense_file/expense_page.dart';
import 'package:sandhut/widgets/pdfVoucherDesign.dart';
import 'package:sandhut/widgets/splashScreen.dart';

import 'app/authentication/login.dart';
import 'app/pages/dashboard/admin_dashboard.dart';
import 'app/pages/tax_invoice/tax_invoice_generator/tax_invoice_pdf.dart';
import 'app/pages/voucher/VoucherEnter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyDxxNq-33-dYAGO0rl9nFPhslOYKh_xHoE",
    authDomain: "sandhut-7353.firebaseapp.com",
    projectId: "sandhut-7353",
    messagingSenderId: "277386462714",
    appId: "1:277386462714:web:31af2a9dd04e8e33769043",
    storageBucket: "sandhut-7353.appspot.com",
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SandHut ERP',
      // home: const Side_Menu_Bar(),
      home: ExpenseEnter(),
      // home: const Login(),
      // home: const PdfVoucherDesign(),

    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sandhut/expense_file/purchase_page.dart';
import 'Expense_page.dart';
import 'billing_page.dart';
import 'dashboard_page.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDxxNq-33-dYAGO0rl9nFPhslOYKh_xHoE",
        authDomain: "sandhut-7353.firebaseapp.com",
        projectId: "sandhut-7353",
        messagingSenderId: "277386462714",
        appId: "1:277386462714:web:31af2a9dd04e8e33769043",
      ));
}


class main_Expense_Page extends StatefulWidget {
  const main_Expense_Page({super.key});

  @override
  State<main_Expense_Page> createState() => _main_Expense_PageState();
}

class _main_Expense_PageState extends State<main_Expense_Page> {

  int _selectedIndex = 1;
  bool isExpanded = false;

  int _currentIndex = 1;


  final List<Widget> _pages =[
    DashBoard(),
    BillingPage(),
    ExpensePage(),
    PurchasePage(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text('SANDHUT'),
        backgroundColor: Colors.blue[300],
      ),
      body: Row(
        children: [
          NavigationRail(
              elevation: 1,
              minExtendedWidth: 200,
              minWidth: 100,
              indicatorColor: Colors.blue,
              backgroundColor: Colors.grey.shade300,
              selectedIconTheme: IconThemeData(color: Colors.blue[300]),
              selectedLabelTextStyle: TextStyle(color: Colors.blue),
              extended: isExpanded,
              onDestinationSelected: (int index){
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('DASHBOARD'),
                ),
                NavigationRailDestination(icon: Icon(Icons.note_add), label: Text('BILLING'),
                ),
                NavigationRailDestination(icon: Icon(Icons.money_outlined), label: Text('EXPENSE'),
                ),
                NavigationRailDestination(icon: Icon(Icons.change_circle_outlined), label: Text('PURCHASE'),
                ),
                // Add more NavigationRailDestinations for other options
              ],selectedIndex: _selectedIndex
          ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
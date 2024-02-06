import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:sandhut/app/pages/purchase/perchase_enter.dart';
import 'package:sandhut/app/pages/voucher/pending_voucher_uploads.dart';
import '../../widgets/constrans.dart';
import '../../widgets/splashScreen.dart';
import '../pages/dashboard/admin_dashboard.dart';
import '../pages/expense/expense_enter.dart';
import '../pages/tax_invoice/sales_billing.dart';
import '../pages/voucher/VoucherEnter.dart';


class Side_Menu_Bar extends StatefulWidget {
  const Side_Menu_Bar({super.key});

  @override
  State<Side_Menu_Bar> createState() => _Side_Menu_BarState();
}

class _Side_Menu_BarState extends State<Side_Menu_Bar> {

  int _selectedIndex = 0;
  bool isExpanded = true;

  @override
  void initState(){
    super.initState();
    readCurrent_page();
    print(_pages.length);
  }

  final List<Widget> _pages =[
    AdminDashboard(),
    SalesBilling(),
    PurchaseEnter(),
    ExpenseEnter(),
    VoucherEnter(),
    PendingFilesUpload(),
    SizedBox(),
  ];

void curretPage()async{
  await Hive.openBox('session');
  var box = Hive.box('session');
  box.put('current_page', _selectedIndex);
  var login = box.get('logged_in');
}

void readCurrent_page()async{
  await Hive.openBox('session');
  var box = Hive.box('session');
  var currentPage = box.get('current_page');
  setState(() {
    _selectedIndex = currentPage;
  });
  print(currentPage);
}
  bool mobile = false;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width > 900 ? false : true;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: smartBlue,
          title: Text('SandHut'),
          actions: [
            IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.profile_circled))
          ],
        ),
      body:Row(
        children: [
          NavigationRail(
            elevation: 1,
            minExtendedWidth: 200,
            minWidth: 50,
            indicatorColor: smartBlue,
            backgroundColor: Colors.grey.shade300,
            selectedIconTheme: IconThemeData(color: smartBlue),
            selectedLabelTextStyle: TextStyle(color: smartBlue),
            extended: isExpanded,
            onDestinationSelected: (int index) async {
              if(_selectedIndex == _pages.length-1){
                await Hive.openBox('session');
                var box = Hive.box('session');
                box.put('current_page', 0);
                box.put('logged_in', 'NO');
                Get.offAll(()=>const SplashScreen());
              }else{
                setState(() {
                  _selectedIndex = index;
                });
                print(_selectedIndex);
                curretPage();
              }
            },
              destinations: [
            NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard',style: TextStyle(fontWeight: FontWeight.bold),)),
            NavigationRailDestination(icon: Icon(Icons.edit_document), label: Text('Tax Invoice',style: TextStyle(fontWeight: FontWeight.bold),)),
                NavigationRailDestination(icon: Icon(Icons.shop_two), label: Text('Add Purchase',style: TextStyle(fontWeight: FontWeight.bold),)),
                NavigationRailDestination(icon: Icon(Icons.attach_money), label: Text('Add Expense',style: TextStyle(fontWeight: FontWeight.bold),)),
                NavigationRailDestination(icon: Icon(Icons.money_rounded), label: Text('Add Voucher',style: TextStyle(fontWeight: FontWeight.bold),)),
                NavigationRailDestination(icon: Icon(Icons.pending), label: Text('Pending Voucher',style: TextStyle(fontWeight: FontWeight.bold),)),
                NavigationRailDestination(icon: Icon(Icons.logout), label: Text('Logout',style: TextStyle(fontWeight: FontWeight.bold),)),
          ],
              selectedIndex: _selectedIndex
          ),
          Expanded(child: _pages[_selectedIndex]),
        ],
      )
    );
  }
}

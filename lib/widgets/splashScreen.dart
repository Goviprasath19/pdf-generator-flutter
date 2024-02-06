import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:sandhut/app/authentication/login.dart';
import '../app/components/app.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();
    initialization();
  }
  void initialization() async {
    await Hive.openBox('session');
    var box = Hive.box('session');
    var login = box.get('logged_in');
    print(login);
    await Future.delayed(const Duration(seconds: 1));
    login == 'YES'?Get.offAll(()=>const Side_Menu_Bar()):Get.offAll(()=>const Login());
  }

  bool isLogin = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hello'),
            ],
          )
        ],
      ),
    );
  }
}

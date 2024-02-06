import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:sandhut/widgets/constrans.dart';

import '../../widgets/splashScreen.dart';
import '../components/app.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {


  TextEditingController _companyEmailController = TextEditingController();
  TextEditingController _companyPasswordController = TextEditingController();

  bool passwordVisible = false;

 void _saveContent() async {
   await Hive.openBox('session');
   var box = Hive.box('session');
   box.put('logged_in', 'YES');
   var login = box.get('logged_in');
   print(login);
   Get.offAll(()=>const Side_Menu_Bar());
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 10,
        leading:  Image.asset('assets/image/Logo.png',width: 200,),
        leadingWidth: 200,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child:
                  Container(
                    width: MediaQuery.of(context).size.width*0.4,
                    decoration: BoxDecoration(color: smartBlue.withOpacity(0.5),borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text('Login',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 24),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            color: Colors.white,
                            height: 40,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _companyEmailController,
                                style: TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  labelText: 'Email ID*',
                                  prefixIcon: Icon(
                                    Icons.email,
                                    size: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 2)),
                                  focusedBorder: OutlineInputBorder(
                                    //<-- SEE HERE
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            height: 40,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                obscureText: passwordVisible,
                                controller: _companyPasswordController,
                                style: TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(onPressed: (){
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  }, icon: Icon(CupertinoIcons.eye,size: 16,)),
                                  labelText: 'Password*',
                                  prefixIcon: Icon(
                                    Icons.password,
                                    size: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 2)),
                                  focusedBorder: OutlineInputBorder(
                                    //<-- SEE HERE
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SizedBox(
                                  width:
                                  MediaQuery.of(context).size.width,
                                  height: 40,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: smartBlue,
                                          side: BorderSide(
                                            width: 1.0,
                                            color: Colors.blue.shade900,
                                          ),
                                      ),
                                      onPressed: () {
                                          if(_companyEmailController.text == 'info@sandhut.in' || _companyEmailController.text == 'th@sandhut.in' || _companyEmailController.text == 'nk@sandhut.in' && _companyPasswordController.text =='7353119797'){
                                            _saveContent();
                                          }else{
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
                                                  'Please enter valid User Login'),
                                            ));
                                          }
                                      },
                                      child: Text(
                                        'Login Now',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

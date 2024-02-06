import 'package:flutter/material.dart';

class PdfVoucherDesign extends StatefulWidget {
  const PdfVoucherDesign({super.key});

  @override
  State<PdfVoucherDesign> createState() => _PdfVoucherDesignState();
}

class _PdfVoucherDesignState extends State<PdfVoucherDesign> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white,border: Border.all(color: Colors.black,width: 2)),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SANDHUT INDIA PRIVET LIMITED',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 14),),
                      SizedBox(height: 5,),
                      Row(
                        children: [
                          Text('GSTIN: 29ABKCS1628N1ZP',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10),),
                          SizedBox(width: 3,),
                          Text('CIN:  U72900KA2023PTC170142',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10),),
                        ],
                      ),
                      SizedBox(height: 3,),
                      Text('No. 23 Anugraha Enclave ,Nandagokula Nilaya,',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10),),
                      Text('Kadabegere, Magadi Main Rd ,Nr Janpriya Bangalore,',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10),),
                      Text('Karnataka, India, 562130',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 10),),

                    ],
                  ),
                  Text('PAYMENT VOUCHER',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
          ]
              ),
              Divider(color: Colors.black,),
              Divider(color: Colors.black,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Voucher No:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12),),
                    Text('000239944',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                    Container(
                      height: 20,
                      width: 2,
                      color: Colors.black,
                    ),
                    Text('Date:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12),),
                    Text('03-07-2023',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                  ],
                ),
              ),
              Divider(color: Colors.black,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mode of Payment:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12),),
                    Text('Cash',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                  ],
                ),
              ),
              Divider(color: Colors.black,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Amount:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12),),
                    Text('₹4,500',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                    Container(
                      height: 20,
                      width: 2,
                      color: Colors.black,
                    ),
                    Text('Amount In words:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12),),
                    Text('Five Hundred Only',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                  ],
                ),
              ),
              Divider(color: Colors.black,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('To whom:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12),),
                    Text('Nandakishore Gowda G',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                  ],
                ),
              ),
              Divider(color: Colors.black,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Being:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12),),
                    Text('Ground Maintenance',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                  ],
                ),
              ),
              Divider(color: Colors.black,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Approved By:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12),),
                    Container(
                      height: 60,
                      width: 2,
                      color: Colors.black,
                    ),
                    Text('Paid Seal:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12),),
                    Container(
                      height: 60,
                      width: 2,
                      color: Colors.black,
                    ),
                    Text('Receiver\s Signature:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12),),
                  ],
                ),
              ),
              Divider(color: Colors.black,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('Original Voucher',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 9),),
              ),
              Divider(color: Colors.black,),
            ],
          ),
        ),
      ),
    );
  }
}

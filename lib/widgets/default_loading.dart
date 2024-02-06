import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DefaultLoading extends StatefulWidget {
  const DefaultLoading({super.key});

  @override
  State<DefaultLoading> createState() => _DefaultLoadingState();
}

class _DefaultLoadingState extends State<DefaultLoading> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.3,
                    child: Lottie.asset('assets/lottie/loading.json',width: 150)),
              ],
            ),
          ],
        ),
      );

  }
}

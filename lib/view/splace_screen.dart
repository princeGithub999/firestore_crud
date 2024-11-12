import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authen/view/home_page.dart';
import 'package:firebase_authen/auth/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplaceScreen extends StatefulWidget {
  const SplaceScreen({super.key});

  @override
  State<SplaceScreen> createState() => _SplaceScreenState();
}

class _SplaceScreenState extends State<SplaceScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    splaceWork();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
        [
          Colors.pink,
          Colors.lightBlueAccent.withOpacity(0.5),

        ])
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Image.asset('assets/images/img.png'),
              ),
            ),
            Spacer(),
            Lottie.asset('assets/images/loder.json',width: 100)
          ],
        ),
      ),
    );
  }


  void splaceWork(){
    Timer(Duration(seconds: 2),() {

      if(_auth.currentUser != null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(),));

      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage(),));

      }
    },);
  }
}

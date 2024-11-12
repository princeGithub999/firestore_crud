import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authen/auth/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPassword = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  bool isSignUp = false;

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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome ',style: TextStyle(color: Colors.white,fontSize: 25),),
                  Text('Create your new account',style: TextStyle(color: Colors.white54),),
                  Image.asset('assets/images/img_2.png'),


                  SizedBox(height: 10,),
                  Text('Sign Up',style: TextStyle(color: Colors.white,fontSize: 25),),

                  SizedBox(height: 20,),


                  Card(
                    elevation: 10,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Enter Full Name',
                        contentPadding: EdgeInsets.only(left: 10),

                      ),
                    ),
                  ),
                  Card(
                    elevation: 10,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Enter Address',
                        contentPadding: EdgeInsets.only(left: 10),

                      ),
                    ),
                  ),
                  Card(
                    elevation: 10,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Phone Number',
                        contentPadding: EdgeInsets.only(left: 10),

                      ),
                    ),
                  ),
                  Card(
                    elevation: 10,
                    child: TextField(
                      controller: userEmail,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        contentPadding: EdgeInsets.only(left: 10),

                      ),
                    ),
                  ),

                  Card(
                    elevation: 10,
                    child: TextField(
                      controller: userPassword,
                      decoration: const InputDecoration(
                        hintText: 'Passwordss',
                        contentPadding: EdgeInsets.only(left: 10),

                      ),
                    ),
                  ),

                  SizedBox(height: 40,),
                  ElevatedButton(onPressed: () {
                    signUp();
                  },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                   child: isSignUp ?
                       SizedBox(
                         width: 90,

                         child: const Row(
                          children: [

                            Text('Loding...',style: TextStyle(color: Colors.black),),

                            SizedBox(
                             height: 20,
                             width: 20,
                             child: CircularProgressIndicator(color: Colors.black,),
                           ),
                            SizedBox(width: 5,),
                          ],
                         ),
                       )
                      : Text('Sign In'),
                  ),


                  SizedBox(height: 40,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("I  have an account",style: TextStyle(color: Colors.white),),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignInPage()),
                          );
                        },
                        child:Text('Sign In',style: TextStyle(color: Colors.red),)
                        ,
                      ),

                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signUp() async {
    var user = userEmail.text;
    var password = userPassword.text;

    if (user.isNotEmpty && password.isNotEmpty) {
      startProsses();
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: user,
          password: password,
        );


        Fluttertoast.showToast(msg: 'SignUp success');

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage()),);
        stopProsses();
      } catch (e) {

        Fluttertoast.showToast(msg: '$e');
        stopProsses();
      }
    } else {
      Fluttertoast.showToast(msg: 'please enter all field');
      stopProsses();
    }
  }


  void startProsses(){
    setState(() {
      isSignUp = true;
    });
  }


  void stopProsses(){
    setState(() {
      isSignUp = false;
    });
  }

}

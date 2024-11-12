import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authen/view/home_page.dart';
import 'package:firebase_authen/auth/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Map<String , dynamic>? _userData;


  TextEditingController userEmail = TextEditingController();
  TextEditingController userPassword = TextEditingController();
  bool isLogin = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.pink, Colors.lightBlueAccent.withOpacity(0.5)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  'Welcome Back,',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                const Text(
                  'make it work make it right make it fast',
                  style: TextStyle(color: Colors.white54),
                ),

                Image.asset('assets/images/img_1.png'),

                const SizedBox(height: 10),
                const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 25)),

                const SizedBox(height: 20),
                _buildTextField(userEmail, 'Email'),

                const SizedBox(height: 15),
                _buildTextField(userPassword, 'Password', obscureText: true),

                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: isLogin
                          ? Row(
                        children: const [
                          Text(
                            'Loading...',
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          SizedBox(width: 5),
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.black),
                          ),
                        ],
                      )
                          : const Text('Sign In', style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                _buildSocialSignInButton(),
                const SizedBox(height: 90),
                _buildSignUpText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build Email and Password TextFields
  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
    return Card(
      elevation: 10,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(

          hintText: hintText,
          contentPadding: const EdgeInsets.only(left: 10),
        ),
      ),
    );
  }

  // Build Social Sign-In Buttons
  Widget _buildSocialSignInButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => signInWithGoogle(),
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/search.png'),
            ),
          ),
        ),

        const SizedBox(width: 10),
        InkWell(
          onTap: () {
            facebookLogin();
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/facebook (3).png'),
            ),
          ),
        )
      ],
    );
  }

  // Build Sign-Up Text Button
  Widget _buildSignUpText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("I don't have an account", style: TextStyle(color: Colors.white)),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpPage()),
            );
          },
          child: const Text('Sign Up', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  // Sign In with Email and Password
  Future<void> signIn() async {
    var email = userEmail.text.trim();
    var password = userPassword.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      processStart();

      try {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
        Fluttertoast.showToast(msg: 'Sign In Successful');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error: $e');
      } finally {
        processStop();
      }
    } else {
      Fluttertoast.showToast(msg: 'Please fill in all details');
      processStop();
    }
  }


  // Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
        Fluttertoast.showToast(msg: 'Google auth success');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        Fluttertoast.showToast(msg: 'Google Sign-In aborted');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }



  // facebook Sign-In
  Future<UserCredential> facebookLogin() async {
    final LoginResult loginResult = await FacebookAuth.instance.login(permissions: ['email']);

    if (loginResult.status == LoginStatus.success) {
      // Get user data from Facebook
      final userData = await FacebookAuth.instance.getUserData();
      _userData = userData;

      // Ensure the accessToken is not null
      final accessToken = loginResult.accessToken;
      if (accessToken != null) {
        final OAuthCredential oAuthCredential = FacebookAuthProvider.credential(accessToken.tokenString);
        // Sign in to Firebase with Facebook credentials
        return FirebaseAuth.instance.signInWithCredential(oAuthCredential);
      } else {
        Fluttertoast.showToast(msg: "Facebook access token is null.");
        throw FirebaseAuthException(code: 'ERROR_MISSING_ACCESS_TOKEN', message: "Missing Facebook access token.");
      }
    } else {
      Fluttertoast.showToast(msg: '${loginResult.message}');
      throw FirebaseAuthException(code: 'ERROR_FACEBOOK_LOGIN_FAILED', message: loginResult.message);
    }
  }



  void processStop() {
    setState(() {
      isLogin = false;
    });
  }

  void processStart() {
    setState(() {
      isLogin = true;
    });
  }
}

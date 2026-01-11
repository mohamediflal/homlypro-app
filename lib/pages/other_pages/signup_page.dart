import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'package:home_service/constraints/signup_form.dart';
import 'package:home_service/pages/other_pages/login_page.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F9F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.purple,
                    size: 45,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Success',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your account has been successfully \nregistered',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  //width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 10,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  
     @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
       backgroundColor: Colors.white,
      
      body:SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 205, 187, 223),
                Color.fromARGB(255, 143, 171, 220),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                 Container(
                  height: 400,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: -40,
                        height: 400,
                        width: width,
                        child: FadeInUp(duration: Duration(seconds: 1), child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/background.png'),
                              fit: BoxFit.fill
                            )
                          ),
                        )),
                      ),
                      Positioned(
                        height: 400,
                        width: width+20,
                        child: FadeInUp(duration: Duration(milliseconds: 1000), child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/background-2.png'),
                              fit: BoxFit.fill
                            )
                          ),
                        )),
                      )
          
                      
                    ],
                  ),
                ),
                SizedBox(height: 0),
                 Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(height: 0),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: SignupForm(onSignupSuccess: (username, email, password) {
                    _showSuccessDialog();
                  })),
              ]
            ),
          ),
        ),
      )
    );
  }
}

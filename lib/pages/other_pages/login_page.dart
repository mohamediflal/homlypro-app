import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:home_service/constraints/login_form.dart';
import 'home_page.dart';
import 'admin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // user can't dismiss by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  "Yeah! Welcome Back",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "login successful",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(180, 45),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    ); // navigate to HomePage
                  },
                  child: const Text(
                    "Go to home",
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
               /* Color(0xFFC4BCDE), // lavender
               Color(0xFFE8E2F7),*/
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
                  'Login',
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
                  child: LoginForm(onLoginSuccess: (email, password) {
                      // if admin credentials provided, open AdminPage
                      if (email == 'homlypro@gmail.com' && password == 'Homlypro123') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminPage()),
                        );
                      } else {
                        _showSuccessDialog();
                      }
                    })),
              ]
            ),
          ),
        ),
      )
    );
  }
}
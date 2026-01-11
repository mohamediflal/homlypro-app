import 'package:flutter/material.dart';
import 'package:home_service/constraints/validation/email_validation.dart';
import 'package:home_service/pages/other_pages/login_page.dart';
import 'package:home_service/pages/other_pages/reset_pw.dart';

class ForgotPwPage extends StatefulWidget {
  const ForgotPwPage({super.key});

  @override
  State<ForgotPwPage> createState() => _ForgotPwPageState();
}

class _ForgotPwPageState extends State<ForgotPwPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError; // added
  bool _sending = false;
 
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    setState(() {
      _emailError = EmailValidator.validate(_emailController.text.trim());
    });
  }

  Future<void> _sendResetLink() async {
    _validateEmail();
    if (_emailError != null) return;

    setState(() => _sending = true);
    // simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _sending = false);

    // show custom styled success dialog
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EAF6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Color(0xFF6A2FB7),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Reset Link Sent',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'A password reset link has been sent to ${_emailController.text.trim()}. Please check your email.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const ResetPw()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        elevation: 4,
                      ),
                      child: const Text('Ok',
                          style: TextStyle(color: Colors.white)),
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

  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Forgot Password')),
      body: SizedBox.expand(
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Image.asset(
                      'assets/forgot_pw2.png',
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Don\'t worry! It happens.\n Please enter your email address associated with your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45.0),
                    child: TextField(
                      controller: _emailController,
                      onChanged: (v) {
                        if (_emailError != null) setState(() => _emailError = null);
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Image.asset(
                          'assets/email.png',
                          width: 24,
                          height: 24,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Colors.purple,
                            width: 1.5,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 55),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _emailError!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _sending ? null : _sendResetLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Send Reset Link',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
          
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(right: 0),
                      ),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:home_service/constraints/validation/signup_pw_validation.dart';
import 'package:home_service/pages/other_pages/login_page.dart';

class ResetPw extends StatefulWidget {
  const ResetPw({super.key});

  @override
  State<ResetPw> createState() => _ResetPwState();
}

class _ResetPwState extends State<ResetPw> {
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
                  'Your password has been successfully \nreset',
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

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _passwordError;
  String? _confirmPasswordError;
  bool _obscurePassword = true;
  bool _submitting = false;
  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    setState(() {
      _passwordError = SignupPasswordValidator.validate(
        _passwordController.text,
      );
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      if (_confirmPasswordController.text != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
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
                      'assets/reset_pw.png',
                      width: 400,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Create New Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Create your new password\n Make sure your new password is different from previous used passwords.  ',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 10), //enter new password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (v) {
                            if (_passwordError != null)
                              setState(() => _passwordError = null);
                            if (_confirmPasswordError != null)
                              setState(() => _confirmPasswordError = null);
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter New Password',
                            prefixIcon: Image.asset(
                              'assets/password.png',
                              width: 24,
                              height: 24,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(
                                color: Colors.purple,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        if (_passwordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 8),
                            child: Text(
                              _passwordError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), //confirm new password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword,
                          onChanged: (v) {
                            if (_confirmPasswordError != null)
                              setState(() => _confirmPasswordError = null);
                          },
                          decoration: InputDecoration(
                            hintText: 'Confirm New Password',
                            prefixIcon: Image.asset(
                              'assets/password.png',
                              width: 24,
                              height: 24,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(
                                color: Colors.purple,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        if (_confirmPasswordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 8),
                            child: Text(
                              _confirmPasswordError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 50,
                    width: 420,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),

                      onPressed: _submitting
                          ? null
                          : () async {
                              // validate fields
                              _validatePassword();
                              _validateConfirmPassword();
                              if (_passwordError != null ||
                                  _confirmPasswordError != null)
                                return;
                              // simulate API call / submit
                              setState(() => _submitting = true);
                              await Future.delayed(const Duration(seconds: 1));
                              if (!mounted) return;
                              setState(() => _submitting = false);

                              // on success show dialog (your _showSuccessDialog navigates to Login)
                              _showSuccessDialog();
                            },
                      child: const Text(
                        "Reset Password",
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
          ),
        ),
      ),
    );
  }
}

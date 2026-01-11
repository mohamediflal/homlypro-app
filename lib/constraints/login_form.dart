import 'package:flutter/material.dart';
import 'package:home_service/constraints/validation/email_validation.dart';
import 'package:home_service/constraints/validation/login_pw_validation.dart';
import 'package:home_service/pages/other_pages/signup_page.dart';
import 'package:home_service/pages/other_pages/forgot_pw.dart';

class LoginForm extends StatefulWidget {
  final Function(String email, String password) onLoginSuccess;

  const LoginForm({super.key, required this.onLoginSuccess});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  void _validateAndLogin() {
    _validateEmail();
    _validatePassword();

    if (_emailError == null && _passwordError == null) {
      widget.onLoginSuccess(_emailController.text, _passwordController.text);
    }
  }

  void _validateEmail() {
    setState(() {
      _emailError = EmailValidator.validate(_emailController.text);
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError = LoginPasswordValidator.validate(
        _passwordController.text,
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Email
        SizedBox(height: 1),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _emailController,
                onChanged: (v) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Image.asset(
                    'assets/email.png',
                    width: 24,
                    height: 24,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.purple, width: 1.5),
                  ),
                ),
              ),
              if (_emailError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 8),
                  child: Text(
                    _emailError!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),

        // Password
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (v) {
                  if (_passwordError != null)
                    setState(() => _passwordError = null);
                },
                decoration: InputDecoration(
                  hintText: 'Password',
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
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.purple, width: 1.5),
                  ),
                ),
              ),
              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 8),
                  child: Text(
                    _passwordError!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () {
              // Handle forgot password action
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ForgotPwPage()),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(right: 0),
            ),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _validateAndLogin,
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
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.center,

          child: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(right: 0),
            ),
            child: const Text(
              'Create Account?',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

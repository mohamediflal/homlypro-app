import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:home_service/constraints/validation/email_validation.dart';
import 'package:home_service/constraints/validation/signup_name_validation.dart';
import 'package:home_service/constraints/validation/signup_pw_validation.dart';
import 'package:home_service/pages/other_pages/login_page.dart';

class SignupForm extends StatefulWidget {
  final Function(String username, String email, String password)
  onSignupSuccess;

  const SignupForm({super.key, required this.onSignupSuccess});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;
  //bool _agreeToTerms = false;
  late TapGestureRecognizer _tosRecognizer;
  late TapGestureRecognizer _ppRecognizer;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _tosRecognizer.dispose();
    _ppRecognizer.dispose();
    super.dispose();
  }

  bool _validateAll() {
    _validateUsername();
    _validateEmail();
    _validatePassword();
    return _usernameError == null &&
        _emailError == null &&
        _passwordError == null;
  }

  void _onSubmit() {
    if (_validateAll()) {
      widget.onSignupSuccess(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _validateUsername() {
    setState(() {
      _usernameError = SignupUsernameValidator.validate(
        _usernameController.text,
      );
    });
  }

  void _validateEmail() {
    setState(() {
      _emailError = EmailValidator.validate(_emailController.text);
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError = SignupPasswordValidator.validate(
        _passwordController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _usernameController,
                onChanged: (v) {
                  _validateUsername();
                },
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  prefixIcon: Image.asset(
                    'assets/user-outline.png',
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
              ),
              if (_usernameError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 8),
                  child: Text(
                    _usernameError!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
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
              // 👇 Show red text if invalid
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

        const SizedBox(height: 0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          // single child for Padding: a Column containing TextField + Forgot row
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (v) {
                  _validatePassword(); // validate live as user types
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
              ),
              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 8),
                  child: Text(
                    _passwordError!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),

              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),

                  onPressed: _onSubmit,
                  child: const Text(
                    "Sign Up",
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
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account?'),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.purple),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:home_service/constraints/validation/email_validation.dart';
import 'package:home_service/constraints/validation/login_pw_validation.dart';
import 'package:home_service/pages/other_pages/employee_signup_page.dart';
import 'package:home_service/services/employee_auth_service.dart';

class EmployeeLoginForm extends StatefulWidget {
  final Function(String employeeId, Map<String, dynamic> employeeData)
      onLoginSuccess;

  const EmployeeLoginForm({super.key, required this.onLoginSuccess});

  @override
  State<EmployeeLoginForm> createState() => _EmployeeLoginFormState();
}

class _EmployeeLoginFormState extends State<EmployeeLoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final EmployeeAuthService _employeeAuthService = EmployeeAuthService();
  String? _emailError;
  String? _passwordError;
  String? _authError;
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _validateAndLogin() async {
    _validateEmail();
    _validatePassword();

    if (_emailError == null && _passwordError == null) {
      setState(() {
        _isLoading = true;
        _authError = null;
      });

      final result = await _employeeAuthService.signInEmployee(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        widget.onLoginSuccess(
          result['employeeId'],
          result['employeeData'],
        );
      } else {
        setState(() {
          _authError = result['error'];
        });
        _showErrorSnackbar(result['error']);
      }
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
        const SizedBox(height: 1),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _emailController,
                onChanged: (v) {
                  if (_emailError != null) _validateEmail();
                },
                decoration: InputDecoration(
                  labelText: 'Work Email',
                  hintText: 'Enter your work email',
                  errorText: _emailError,
                  prefixIcon: const Icon(Icons.email, color: Colors.purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.purple, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                onChanged: (v) {
                  if (_passwordError != null) _validatePassword();
                },
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  errorText: _passwordError,
                  prefixIcon: const Icon(Icons.lock, color: Colors.purple),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.purple, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isLoading ? null : _validateAndLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Login as Employee',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmployeeSignupPage(),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Register',
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

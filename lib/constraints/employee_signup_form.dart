import 'package:flutter/material.dart';
import 'package:home_service/constraints/validation/email_validation.dart';
import 'package:home_service/constraints/validation/signup_name_validation.dart';
import 'package:home_service/constraints/validation/signup_pw_validation.dart';
import 'package:home_service/pages/other_pages/employee_login_page.dart';
import 'package:home_service/services/employee_auth_service.dart';

class EmployeeSignupForm extends StatefulWidget {
  final Function(String employeeId, String name, String email)
      onSignupSuccess;

  const EmployeeSignupForm({super.key, required this.onSignupSuccess});

  @override
  State<EmployeeSignupForm> createState() => _EmployeeSignupFormState();
}

class _EmployeeSignupFormState extends State<EmployeeSignupForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final EmployeeAuthService _employeeAuthService = EmployeeAuthService();
  
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _authError;
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  String _selectedServiceType = 'Cleaning';
  final List<String> _serviceTypes = [
    'Cleaning',
    'Plumber',
    'Electrician',
    'Painter',
    'Carpenter',
    'Gardener',
    'Cook',
    'Driver',
    'Mechanic',
    'Tailor',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateAll() {
    _validateName();
    _validateEmail();
    _validatePhone();
    _validatePassword();
    return _nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null;
  }

  Future<void> _onSubmit() async {
    if (_validateAll()) {
      setState(() {
        _isLoading = true;
        _authError = null;
      });

      final result = await _employeeAuthService.registerEmployee(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        serviceType: _selectedServiceType,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        widget.onSignupSuccess(
          result['employeeId'],
          _nameController.text.trim(),
          _emailController.text.trim(),
        );
      } else {
        setState(() {
          _authError = result['error'];
        });
        _showErrorSnackbar(result['error']);
      }
    }
  }

  void _validateName() {
    setState(() {
      _nameError = SignupUsernameValidator.validate(_nameController.text);
    });
  }

  void _validateEmail() {
    setState(() {
      _emailError = EmailValidator.validate(_emailController.text);
    });
  }

  void _validatePhone() {
    setState(() {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        _phoneError = 'Phone number is required';
      } else if (phone.length < 10) {
        _phoneError = 'Phone number must be at least 10 digits';
      } else if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(phone)) {
        _phoneError = 'Invalid phone number format';
      } else {
        _phoneError = null;
      }
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError = SignupPasswordValidator.validate(
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            TextField(
              controller: _nameController,
              onChanged: (v) {
                if (_nameError != null) _validateName();
              },
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                errorText: _nameError,
                prefixIcon: const Icon(Icons.person, color: Colors.purple),
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
            const SizedBox(height: 16),
            
            // Email
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
            const SizedBox(height: 16),
            
            // Phone
            TextField(
              controller: _phoneController,
              onChanged: (v) {
                if (_phoneError != null) _validatePhone();
              },
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                errorText: _phoneError,
                prefixIcon: const Icon(Icons.phone, color: Colors.purple),
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
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            // Service Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedServiceType,
              decoration: InputDecoration(
                labelText: 'Service Type',
                prefixIcon: const Icon(Icons.work, color: Colors.purple),
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
              items: _serviceTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedServiceType = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Password
            TextField(
              controller: _passwordController,
              onChanged: (v) {
                if (_passwordError != null) _validatePassword();
              },
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Create a password',
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
            
            // Submit Button
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
                onPressed: _isLoading ? null : _onSubmit,
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
                        'Register as Employee',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Login Link
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployeeLoginPage(),
                    ),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(text: "Already have an account? "),
                      TextSpan(
                        text: 'Login',
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
    );
  }
}

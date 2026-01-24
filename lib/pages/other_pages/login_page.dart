import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:home_service/constraints/login_form.dart';
import 'package:home_service/constraints/employee_login_form.dart';
import 'package:home_service/services/admin_setup.dart';
import 'package:home_service/pages/other_pages/employee_dashboard_page.dart';
import 'home_page.dart';
import 'admin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isEmployeeLogin = false;

  Future<void> _handleLoginSuccess() async {
    // Check if user is admin
    final isAdmin = await AdminSetup.isCurrentUserAdmin();
    
    if (!mounted) return;
    
    // Capture the parent context BEFORE the dialog builder
    final parentContext = context;
    
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
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
                  decoration: const BoxDecoration(
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
                Text(
                  isAdmin ? "Welcome Admin!" : "Yeah! Welcome Back",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAdmin ? "Login successful - Admin access" : "Login successful",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdmin ? Colors.purple : Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(180, 45),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (!mounted) return;
                      
                      Navigator.pushReplacement(
                        parentContext,
                        MaterialPageRoute(
                          builder: (_) => isAdmin ? const AdminPage() : const HomePage(),
                        ),
                      );
                    });
                  },
                  child: Text(
                    isAdmin ? "Go to Admin Dashboard" : "Go to home",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleEmployeeLoginSuccess(
      String employeeId, Map<String, dynamic> employeeData) {
    if (!mounted) return;

    final parentContext = context;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
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
                  decoration: const BoxDecoration(
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
                Text(
                  "Welcome ${employeeData['name'] ?? 'Employee'}!",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Login successful - Employee access",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(180, 45),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);

                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (!mounted) return;

                      Navigator.pushReplacement(
                        parentContext,
                        MaterialPageRoute(
                          builder: (_) => EmployeeDashboardPage(
                            employeeId: employeeId,
                            employeeData: employeeData,
                          ),
                        ),
                      );
                    });
                  },
                  child: const Text(
                    "Go to Dashboard",
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
                        child: FadeInUp(
                          duration: const Duration(seconds: 1),
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/background.png'),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        height: 400,
                        width: width + 20,
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/background-2.png'),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 16,
                        child: SafeArea(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.purple),
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isEmployeeLogin = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: !_isEmployeeLogin
                                  ? Colors.purple
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Customer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: !_isEmployeeLogin
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => setState(() => _isEmployeeLogin = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _isEmployeeLogin
                                  ? Colors.purple
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Employee',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isEmployeeLogin
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16,
                  ),
                  child: _isEmployeeLogin
                      ? EmployeeLoginForm(
                          onLoginSuccess: _handleEmployeeLoginSuccess,
                        )
                      : LoginForm(
                          onLoginSuccess: (email, password) {
                            _handleLoginSuccess();
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
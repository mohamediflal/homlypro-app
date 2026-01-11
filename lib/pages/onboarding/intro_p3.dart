import 'package:flutter/material.dart';
import 'package:home_service/pages/other_pages/login_page.dart';

class IntroP3 extends StatelessWidget {
  const IntroP3({super.key});

  Widget _serviceTile(IconData icon, String label,
      {bool highlighted = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: highlighted
                ? Border.all(color: Colors.blue.shade200, width: 2)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Icon(icon, color: Colors.black54, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black87),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 205, 187, 223),
              Color.fromARGB(255, 143, 171, 220),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 205, 187, 223),
                      Color.fromARGB(255, 143, 171, 220),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 0),
                    // grid of services
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 205, 187, 223),
                            Color.fromARGB(255, 143, 171, 220),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 0.95),
                        children: [
                          _serviceTile(Icons.cleaning_services, 'Cleaning'),
                          _serviceTile(Icons.plumbing, 'Plumber'),
                          _serviceTile(Icons.electrical_services, 'Electrician'),
                          _serviceTile(Icons.format_paint, 'Painter'),
                          _serviceTile(Icons.build, 'Mechanic'),
                          _serviceTile(Icons.park, 'Gardener'),
                          _serviceTile(Icons.content_cut, 'Tailor'),
                          _serviceTile(Icons.room_service, 'Maid'),
                          _serviceTile(Icons.drive_eta, 'Driver'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                    const Text(
                      'Easy, reliable way to take care of your home',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'We provide you with the best people to help take care of your home.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

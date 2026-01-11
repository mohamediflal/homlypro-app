import 'package:flutter/material.dart';

class IntroP2 extends StatelessWidget {
  const IntroP2({super.key});

  Widget buildStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 22),
          ),
          const SizedBox(width: 18),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.deepPurple, size: 22),
    );
  }

  Widget _stepLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC4BCDE),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration / Icon
            Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/intro22.png',
                  fit: BoxFit.cover,
                  width: 180,
                  height: 180,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Title
            const Text(
              "Book Home Services in Minutes",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            const Text(
              "Choose a service, pick a professional, and relax at home.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 25),

            // Steps (icons column + labels column to keep alignment)
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 0),
                      _stepIcon(Icons.category),
                      const SizedBox(height: 10),
                      _stepIcon(Icons.verified_user),
                      const SizedBox(height: 10),
                      _stepIcon(Icons.home),
                    ],
                  ),
                  const SizedBox(width: 18,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      _stepLabel("Choose a Service"),
                      const SizedBox(height: 35),
                      _stepLabel("Trusted Professionals"),
                      const SizedBox(height: 35),
                      _stepLabel("Doorstep Service"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

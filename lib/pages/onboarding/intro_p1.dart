import 'package:flutter/material.dart';

class IntroP1 extends StatelessWidget {
  const IntroP1({super.key});

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
        child: SafeArea(
          child: Column(
               mainAxisAlignment: MainAxisAlignment.start,
            children: [
                 const SizedBox(height: 10),
              // App logo
                 Image.asset(
                   'assets/homlypro_logo.png',
                   width: 400,
                   height: 400,
                   fit: BoxFit.contain,
                 ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Welcome to HomlyPro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Your trusted home service partner',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
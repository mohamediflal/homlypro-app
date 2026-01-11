import 'package:flutter/material.dart';
import 'package:home_service/pages/onboarding/intro_p3.dart';
import 'package:home_service/pages/other_pages/login_page.dart';
import 'package:home_service/pages/onboarding/intro_p1.dart';
import 'package:home_service/pages/onboarding/intro_p2.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboatdingScreen1 extends StatefulWidget {
  const OnboatdingScreen1({super.key});

  @override
  State<OnboatdingScreen1> createState() => _OnboatdingScreen1State();
}

class _OnboatdingScreen1State extends State<OnboatdingScreen1> {
  PageController _controller = PageController();
  bool onLastPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [IntroP1(), IntroP2(), IntroP3()],
          ),
          Positioned(
            bottom: 24, // move this row closer to the bottom; adjust value as needed
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _controller.jumpToPage(2);
                      },
                      child: Text("Skip", style: TextStyle(fontSize: 18)),
                    ),
                    SmoothPageIndicator(controller: _controller, count: 3),
                    onLastPage
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                            },
                            child: Text("Done", style: TextStyle(fontSize: 18)),
                          )
                        : GestureDetector(
                            onTap: () {
                              _controller.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeIn,
                              );
                            },
                            child: Text("Next", style: TextStyle(fontSize: 18)),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'gridp.dart';
import 'show.dart';
import 'sketchpage.dart';

class Button extends StatefulWidget {
  const Button({Key? key}) : super(key: key);

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  final PageController _pageController = PageController();
  int _currentIndex = 1;
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 32, 61, 88),
      body: PageStorage(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            PageStorage(child: TabbedScreen(), bucket: _bucket),
            PageStorage(child: HomePage(), bucket: _bucket),
            PageStorage(child: SketchConverterApp(), bucket: _bucket),
          ],
        ),
        bucket: _bucket,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Color.fromARGB(232, 125, 121, 120),
        backgroundColor: Color.fromARGB(255, 89, 87, 87),
        animationCurve: Curves.ease,
        index: _currentIndex,
        animationDuration: Duration(milliseconds: 300),
        items: [
          Icon(
            Icons.grid_4x4_sharp,
            size: 30,
            color: Color.fromARGB(255, 236, 240, 243),
          ),
          Icon(
            Icons.home,
            size: 30,
            color: Color.fromARGB(255, 236, 240, 243),
          ),
          Icon(
            Icons.draw_sharp,
            size: 30,
            color: Color.fromARGB(255, 236, 240, 243),
          ),
        ],
        height: 50,
        onTap: (newIndex) {
          setState(() {
            _currentIndex = newIndex;
            _pageController.animateToPage(
              newIndex,
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          });
        },
      ),
    );
  }
}

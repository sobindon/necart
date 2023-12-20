import 'package:flutter/material.dart';

class grid extends StatefulWidget {
  const grid({super.key});

  @override
  State<grid> createState() => _gridState();
}

class _gridState extends State<grid> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
        color: Color.fromARGB(255, 196, 18, 18),
        height: 300,
        width: 300,
        child: CustomPaint(
          foregroundPainter: Linepainter(),
        ),
      )),
    );
  }
}

class Linepainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawLine(Offset(size.width * 1 / 6, size.width * 1 / 2),
        Offset(size.width * 5 / 6, size.width * 1 / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

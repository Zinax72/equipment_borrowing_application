import 'package:flutter/material.dart';

class CampusBackdrop extends StatelessWidget {
  const CampusBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/BULSU_BG.png', fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF791B3A).withValues(alpha: 0.55),
                const Color(0xFF791B3A).withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

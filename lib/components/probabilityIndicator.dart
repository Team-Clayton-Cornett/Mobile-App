import 'dart:math';

import 'package:flutter/material.dart';

class ProbabilityIndicator extends StatelessWidget {
  final double diameter;
  final double probability;

  double _greenPercent;
  double _redPercent;

  ProbabilityIndicator({
    @required this.diameter,
    @required this.probability
  }) {
    // Based on https://stackoverflow.com/questions/25007/conditional-formatting-percentage-to-color-conversion
    _greenPercent = min(2.0 - (probability * 2), 1.0);
    _redPercent = min(probability * 2, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(diameter / 2),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, (_redPercent * 255).round(), (_greenPercent * 255).round(), 0),
          border: Border.all(
              color: Colors.white,
              width: 3.0
          ),
        ),
      ),
    );
  }
}
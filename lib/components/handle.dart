import 'package:flutter/material.dart';

class Handle extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  Handle({
    @required this.width,
    @required this.height,
    this.color = Colors.grey
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(this.height / 2)),
      child: Container(
        height: this.height,
        width: this.width,
        color: this.color,
      ),
    );
  }
}
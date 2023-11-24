import 'package:flutter/material.dart';


class CircularPerson extends StatelessWidget {
  final double size;
  const CircularPerson({this.size = 80, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.white.withOpacity(.95)
      ),
      padding: EdgeInsets.all(size * 0.2),
      child: Icon(Icons.person, size: size, color: Colors.blue),
    );
  }
}

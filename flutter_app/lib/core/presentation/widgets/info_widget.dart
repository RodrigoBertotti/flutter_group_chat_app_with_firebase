


import 'package:flutter/material.dart';

class InfoWidget extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry margin;

  const InfoWidget({required this.text, super.key, this.margin = const EdgeInsets.only()});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        decoration: BoxDecoration(
            color: Colors.blue[200],
            borderRadius: BorderRadius.circular(15)
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color:  Colors.indigo[900],),
              const SizedBox(width: 5,),
              Text(text, style: TextStyle(color: Colors.indigo[900], fontSize: 15, letterSpacing: .8, fontWeight: FontWeight.w600)),
            ],
          ),
        )
    );
  }
}

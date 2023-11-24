import 'package:flutter/material.dart';


class PersonIcon extends StatelessWidget {
  final bool isGroup;
  final double iconSize;
  final double borderWidth;
  final EdgeInsets? iconInternalPadding;

  const PersonIcon({required this.isGroup, this.iconSize = 26, this.borderWidth = 0, this.iconInternalPadding, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: isGroup ? Colors.indigo[800] : Colors.blue,
          border: borderWidth > 0 ? Border.all(color: Colors.white, width: borderWidth) : null,
      ),
      padding: iconInternalPadding ?? const EdgeInsets.all(7),
      child: Icon(isGroup ? Icons.group : Icons.person, size: iconSize, color: Colors.white),
    );
  }
}

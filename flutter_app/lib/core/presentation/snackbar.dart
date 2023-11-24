


import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/main.dart';

void showSnackBarWarning ({required String message, Color? backgroundColor}) {
  return showSnackBar(
    message: message,
    backgroundColor: Colors.indigo[900],
    icon: Icons.warning,
    iconColor: Colors.yellow,
  );
}

void showSnackBar ({required String message, Color? backgroundColor, IconData? icon, Color? iconColor}) {
  final radius = Radius.circular(15);
  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
    backgroundColor: backgroundColor ?? Colors.indigo[900],
    duration: const Duration(seconds: 4),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: radius, topRight: radius)
      ),
    content: Row(
      children: [
        Icon(icon ?? Icons.info, size: 24, color: iconColor ?? Colors.white,),
        const SizedBox(width: 6,),
        Flexible(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),))
      ],
    ),
  ));
}
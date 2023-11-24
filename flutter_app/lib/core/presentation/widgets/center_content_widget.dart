import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_group_chat_app_with_firebase/main.dart';


/// Centers the `child` without a delimited container,
/// so we are able to create animations outside this widget,
/// like adding items to a list coming from the left or right
class CenterContentWidget extends StatelessWidget {
  final Widget child;
  final BoxDecoration? decoration;

  const CenterContentWidget({required this.child, this.decoration, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double horizontalMarginSide () {
      return math.max(0, (MediaQuery.of(context).size.width - kPageContentWidth) / 2);
    }
    return Container(
        clipBehavior: Clip.none,
        decoration: decoration,
        child: Align(
            alignment: Alignment.topCenter,
            child: Builder(
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: horizontalMarginSide(),
                        right: horizontalMarginSide(),
                    ),
                    child: SafeArea(child: child,),
                  );
                })
        )
    );
  }
}

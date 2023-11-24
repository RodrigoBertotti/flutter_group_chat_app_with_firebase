import 'package:flutter/material.dart';
import 'dart:math' as math;

typedef NewConstraints = BoxConstraints? Function(BoxConstraints currentConstraints);

class BalloonWidget extends StatelessWidget {
  final Widget? centerChild;
  final bool isLeftSide;
  final bool showCurve;
  final NewConstraints? centerChildConstraints;
  final EdgeInsetsGeometry margin;
  final _curveRadius = const Radius.circular(8);
  const BalloonWidget({ Key? key, this.centerChildConstraints, this.centerChild, this.margin = const EdgeInsets.only(bottom: 6), this.showCurve = true, required this.isLeftSide, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double kWidth = 11.0;
    const double kHeight = 10.0;

    final curve = showCurve ? Padding(
      padding: isLeftSide ? const EdgeInsets.only(left: 1) : const EdgeInsets.only(left: kWidth),
      child: Transform(
        transform: isLeftSide ? Matrix4.rotationY(0) : Matrix4.rotationY(math.pi),
        child: ClipPath(
          clipper: _SideWidgetClipper(),
          child: Container(
            width: kWidth,
            height: kHeight,
            color: isLeftSide ? Colors.white : Colors.indigo[700],
          ),
        ),
      ),
    ) : const SizedBox(width: kWidth,);

    final leftSideChild = isLeftSide ? curve : null;
    final rightSideChild = isLeftSide ? null : curve;

    return Align(
      alignment: rightSideChild != null ? Alignment.bottomRight : Alignment.bottomLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
              padding: margin,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(leftSideChild != null)
                    leftSideChild,
                  Container(
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.only(left: 11, right: 11, top: 6, bottom: 2),
                      decoration: BoxDecoration(
                        color: rightSideChild != null ? Colors.indigo[700] : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.55),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(5 * (rightSideChild != null ? -1 : 1), 5), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.only(
                          topLeft: rightSideChild != null || !showCurve ? _curveRadius : Radius.zero,
                          bottomRight: _curveRadius,
                          bottomLeft: _curveRadius,
                          topRight: rightSideChild != null ? Radius.zero : _curveRadius,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if(centerChild != null)
                            Container(
                              constraints: centerChildConstraints == null ? constraints : centerChildConstraints!(constraints),
                              child: centerChild!,
                            ),
                        ],
                      )
                  ),
                  if(rightSideChild != null)
                    rightSideChild,
                ],
              )
          );
        },
      ),
    );
  }
}

class _SideWidgetClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.quadraticBezierTo(
        size.width * 0.75,
        size.height / 6,
        size.width,
        size.height
    );
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
import 'package:flutter/material.dart';

import 'clipper/waves_background_clipper.dart';


class WavesBackground extends StatelessWidget {
  final bool waveOnTop;
  const WavesBackground({Key? key, this.waveOnTop = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Colors.blue[900]!,
                    Colors.blue[800]!,
                    Colors.blue[900]!,
                  ]
              )
          ),
        ),
        SizedBox(
          height: waveOnTop ? (MediaQuery.of(context).size.height * .38) : (MediaQuery.of(context).size.height * .43),
          child: ClipPath(
            clipper: WavesBackgroundClipper(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Colors.blue[400]!,
                        Colors.blue[300]!,
                        Colors.blue[400]!,
                      ]
                  )
              ),
            ),
          ),
        ),
      ],
    );
  }
}

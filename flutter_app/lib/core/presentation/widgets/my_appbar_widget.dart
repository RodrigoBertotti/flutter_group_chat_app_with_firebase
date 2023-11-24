import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/main.dart';

import 'center_content_widget.dart';

const double _height = 50;
const double _leftIconSize = 28;
const double _leftIconPaddingSide = 2;

class MyAppBarWidget extends PreferredSize{

  MyAppBarWidget({super.key, required BuildContext context, Widget? child, bool withBackground = true}) : super(
      preferredSize: const Size(double.infinity, _height),
      child: Container(
        color: Colors.blue[800]!,
        child: SafeArea(
          child: Container(
            decoration: !withBackground ? null : BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Colors.blue[900]!,
                      Colors.blue[800]!,
                      Colors.blue[900]!,
                    ]
                ),
                boxShadow: [
                  BoxShadow(color: Colors.blue[900]!, offset: const Offset(0,0), spreadRadius: 2, blurRadius: 1)
                ]
            ),
            child: CenterContentWidget(
              decoration: BoxDecoration(color: Colors.blue[900]),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  children: [
                    //on left
                    FutureBuilder(
                      future: Future.delayed(const Duration(milliseconds: 250)),
                      builder: (context, _) {
                        if(Navigator.of(context).canPop()) {
                          return InkWell(
                            child: Ink(
                              child: const Icon(Icons.keyboard_arrow_left_rounded, color: Colors.white, size: _leftIconSize),
                            ),
                            onTap: () {
                              Navigator.of(navigatorKey.currentContext!).pop();
                            },
                          );
                        }
                        return Container();
                      },
                    ),

                    // on center
                    Expanded(
                      child: SizedBox(
                        height: _height,
                        child: Center(
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            )
          ),
        ),
      )
  );
}


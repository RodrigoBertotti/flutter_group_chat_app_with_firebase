import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/core/presentation/widgets/center_content_widget.dart';
import '../../../main.dart';

final noBackground = Container();
final defaultBackground = Container(
  decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [
            Colors.blue[600]!,
            Colors.blue[400]!,
            Colors.blue[600]!,
          ]
      )
  ),
);
final background2Colors = Container(
  decoration: const BoxDecoration(
      gradient: LinearGradient(
          colors: [
            Color(0xff4984f2),
            Color(0xff87b3ff),
          ]
      )
  ),
);

class MyScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? background;
  final EdgeInsets padding;

  const MyScaffold({this.appBar, this.padding = const EdgeInsets.symmetric(horizontal: kMargin, vertical: kMargin), required this.body, this.floatingActionButton, this.background, super.key});

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(child: background ?? defaultBackground),
        Scaffold(
          appBar: appBar,
          backgroundColor: Colors.transparent,
          body: CenterContentWidget(
            child: Padding(
              padding: padding,
              child: body,
            ),
          ),
          floatingActionButton: floatingActionButton,
        ),
      ],
    );
  }
}

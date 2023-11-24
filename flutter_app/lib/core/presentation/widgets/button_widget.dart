import 'package:flutter/material.dart';


class ButtonWidget extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final bool isLoading;
  final bool isSmall;
  final IconData? icon;
  final Color? backgroundColor;
  final double? width;

  const ButtonWidget({Key? key, this.isSmall = false, this.width, this.backgroundColor, this.icon, required this.text, this.onPressed, this.isLoading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? (!isSmall ? double.infinity : null),
      height: isSmall ? 30 : 42,
      child: ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(0),
            backgroundColor: backgroundColor != null ? MaterialStateProperty.all(backgroundColor) : MaterialStateProperty.all(Colors.indigo[900]),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                )
            )
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white),),)
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              ...[
                Icon(icon!, color: Colors.white),
                const SizedBox(width: 6,),
              ],
            Flexible(child: FittedBox(child: Text(text, style: TextStyle(color: Colors.white, fontSize: isSmall ? 12 : 15, letterSpacing: 2, fontWeight: FontWeight.w700)),))
          ],
        ),
      ),
    );
  }
}

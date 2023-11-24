import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/core/presentation/widgets/button_widget.dart';




Future<bool> showConfirmationModal ({required BuildContext context, String title = "Are you sure?", String? message, String confirmButtonText = 'CONFIRM'}) async {
  const kConfirmedResult = '_confirmed_';
  const radius = Radius.circular(20);
  return (await showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: radius, topRight: radius)
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: TextStyle(color: Colors.indigo[900], fontSize: 18, fontWeight: FontWeight.w700),),
              if (message != null)
                ...[
                  const SizedBox(height: 8,),
                  Text(message, style: TextStyle(color: Colors.indigo[600], fontSize: 16, fontWeight: FontWeight.w500),),
                ],
              const SizedBox(height: 14,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ButtonWidget(text: 'CANCEL', isSmall: true, onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 30,),
                  ButtonWidget(
                    text: confirmButtonText,
                    isSmall: true,
                    backgroundColor: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop(kConfirmedResult);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      })) == kConfirmedResult;
}
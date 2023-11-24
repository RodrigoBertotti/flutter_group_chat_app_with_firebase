import 'package:flutter/material.dart';
import '../controllers/signout_controller.dart';

class SignOutButtonWidget extends StatelessWidget {
  final signOutController = SignOutController();

  SignOutButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        signOutController.signOut(context);
      },
      child: Ink(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: BorderRadius.circular(10)
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Icon(Icons.logout_outlined, color: Colors.blue[50]!,),
        ),
      ),
    );
  }
}

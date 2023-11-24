import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/screen_routes.dart';
import '../../../../core/domain/services/auth_service.dart';
import '../../../../injection_container.dart';

class SignOutController {

  void signOut(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 200), getIt.get<AuthService>().signOut);
    Navigator.of(context).pushNamedAndRemoveUntil(ScreenRoutes.login, (route) => false);
  }

}

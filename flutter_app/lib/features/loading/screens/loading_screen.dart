import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/notifications_service.dart';
import '../../../core/domain/services/auth_service.dart';
import '../../../core/presentation/widgets/my_scaffold.dart';
import '../../../core/presentation/widgets/waves_background/waves_background.dart';
import '../../../injection_container.dart';
import '../../../screen_routes.dart';


class LoadingScreen extends StatelessWidget {
  static const String route = '/';

  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start(context);
    });

    return const MyScaffold(
      background: WavesBackground(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white,),
            SizedBox(height: 15,),
            Text("Loading...", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  void _start(BuildContext context) {
    if (getIt.get<AuthService>().isAuthenticated) {
      Navigator.of(context).pushNamedAndRemoveUntil(ScreenRoutes.conversations, (_) => false);
      getIt.get<NotificationsService>().start();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(ScreenRoutes.login, (_) => false);
    }
  }
}

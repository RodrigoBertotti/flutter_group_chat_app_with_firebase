import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/core/presentation/widgets/person_icon.dart';
import 'package:flutter_group_chat_app_with_firebase/screen_routes.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'core/domain/services/notifications_service.dart';
import 'core/presentation/widgets/center_content_widget.dart';
import 'injection_container.dart' as injection_container;
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await injection_container.init();
  runApp(MyApp());
}

const double kMargin = 16.0;
const double kPageContentWidth = 600;
const double kIconSize = 24.0;

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final double height = 100;
  final ValueNotifier<RemoteMessage?> notificationNotifier = ValueNotifier(null);
  final PanelController topNotificationController = PanelController();
  late final Function() unsubscribeOnMessageOpenedApp;

  MyApp({super.key}) {
    unsubscribeOnMessageOpenedApp = getIt.get<NotificationsService>().onMessageOpenedApp(_onMessageOpenedApp);

    // If the app was completed closed and the notification was clicked
    FirebaseMessaging.instance.getInitialMessage().then((remoteMessage){
      if (remoteMessage != null) {
        getIt.get<NotificationsService>().onNotificationClicked(remoteMessage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      builder: (context, widget) => Stack(
        children: [
          MaterialApp(
              title: 'Flutter Group Chat App with Firebase',
              debugShowCheckedModeBanner: false,
              initialRoute: ScreenRoutes.loading, /// Check this file to see how the App starts: lib/features/loading/screens/loading_screen.dart
              theme: ThemeData(
                primarySwatch: Colors.indigo,
                fontFamily: 'RedHatDisplay',
              ),
              routes: screenRoutes,
              navigatorKey: navigatorKey,
          ),
          CenterContentWidget(
            child: Align(
              alignment: const Alignment(0, -1),
              child: IntrinsicHeight(
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.none,
                  child: SlidingUpPanel(
                    borderRadius: BorderRadius.circular(15),
                    slideDirection: SlideDirection.DOWN,
                    controller: topNotificationController,
                    renderPanelSheet: false,
                    isDraggable: true,
                    onPanelClosed: () => notificationNotifier.value = null,
                    minHeight: 0,
                    maxHeight: 105,
                    panel: Container(
                      clipBehavior: Clip.none,
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: notificationNotifier,
                        builder: (context, notification, _) {
                          if (notification == null) {
                            return Container();
                          }
                          return _RemoteMessageContent(
                            notification: notification,
                            onTap: () {
                              getIt.get<NotificationsService>().onNotificationClicked(notification);
                              topNotificationController.close();
                            }
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Timer? _closeNotificationAutomatically;
  void _onMessageOpenedApp(RemoteMessage event) {
    notificationNotifier.value = event;
    topNotificationController.open();

    _closeNotificationAutomatically?.cancel();
    _closeNotificationAutomatically = Timer(const Duration(seconds: 5), () {
      topNotificationController.close();
    });
  }
}

class _RemoteMessageContent extends StatelessWidget {
  final RemoteMessage notification;
  final void Function() onTap;

  const _RemoteMessageContent({required this.notification, required void Function() this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          child: Row(
            children: [
              const PersonIcon(isGroup: false, iconSize: 30),
              const SizedBox(width: 13,),
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(flex: 5, child: Container()),
                      Text(notification.notification!.title!, style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 17, color: Colors.blue[900], fontWeight: FontWeight.w700)),
                      Flexible(flex: 1, child: Container()),
                      Text(notification.notification!.body!, maxLines: 2, style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 16, color: Colors.blue[800], fontWeight: FontWeight.w500)),
                      Flexible(flex: 5, child: Container()),
                    ]
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

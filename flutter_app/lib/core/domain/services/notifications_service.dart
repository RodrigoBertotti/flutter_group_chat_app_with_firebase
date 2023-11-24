import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_group_chat_app_with_firebase/core/data/data_sources/users_ds.dart';
import 'package:flutter/material.dart';
import '../../../features/call/presentation/screens/call_screen.dart';
import '../../../features/chat/presentation/screens/realtime_chat_screen/realtime_chat_screen.dart';
import '../../../main.dart';
import '../../../screen_routes.dart';

// TODO (optional, push notifications for web): replace with your own vapidKey, please follow the instructions: https://stackoverflow.com/a/54996207/4508758
const String _vapidKeyForWeb = "BK...";

class NotificationsService {
  final UsersDS usersDs;
  final FirebaseMessaging messaging;
  late final Stream<RemoteMessage> _onMessage;
  late final Stream<RemoteMessage> _onMessageOpenedApp;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;
  final List<void Function(RemoteMessage event)> onMessageOpenedAppListeners = [];
  String? _ignoreNotificationsForConversationId;

  NotificationsService({required this.messaging, required this.usersDs, required Stream<RemoteMessage> onMessage, required Stream<RemoteMessage> onMessageOpenedApp}) {
    _onMessage = onMessage;
    _onMessageOpenedApp = onMessageOpenedApp;
  }

  /// Adds a handler to when the user receives a message with the app opened.
  ///
  /// Returns a unsubscribe function
  void Function() onMessageOpenedApp(void Function(RemoteMessage event) handler) {
    onMessageOpenedAppListeners.add(handler);
    return () {
      onMessageOpenedAppListeners.remove(handler);
    };
  }

  /// when the user receives a message with the app opened
  _triggerOnMessage(RemoteMessage event) {
    final conversationId = event.data["conversationId"];
    if (_ignoreNotificationsForConversationId == conversationId) {
      return;
    }

    for (final handler in List.from(onMessageOpenedAppListeners)) {
      handler(event);
    }
  }

  ignoreNotificationsForConversationId({required String? conversationId}) {
    _ignoreNotificationsForConversationId = conversationId;
  }

  onNotificationClicked(RemoteMessage event) {
    final conversationId = event.data["conversationId"];
    final uidForDirectConversation = event.data["uidForDirectConversation"];
    if (conversationId != null){
      if ('true' == event.data['joinCall']) {
        Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil(ScreenRoutes.call, (route) => route.isFirst, arguments: CallScreenArgs(conversationId: conversationId));
      } else {
        Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil(ScreenRoutes.chat, (route) => route.isFirst, arguments: RealtimeChatScreenArgs(conversationId: conversationId, uidForDirectConversation: uidForDirectConversation));
      }
    }
  }

  bool _started = false;
  Future<void> start () async {
    if (_started) {
      return;
    }
    _started = true;
    if (!(await messaging.isSupported())) {
      print("Firebase Cloud Messaging is not supported in this platform");
      return;
    }
    await messaging.requestPermission();
    await _setTokenOnLoggedUser();
    _onMessageSubscription = _onMessage.listen(_triggerOnMessage);
    _onMessageOpenedAppSubscription = _onMessageOpenedApp.listen(onNotificationClicked);
  }

  Future<void> _setTokenOnLoggedUser () async {
    if (kIsWeb && _vapidKeyForWeb.length < 10) {
      print("-------------------------------------------------------------------------");
      print("--- ⚠️ MISSING \"vapidKey\". A vapidKey is required for push notifications on Web ⚠️");
      print("--- To fix it:");
      print("--- 1. Get your vapidKey on the Firebase Console: https://stackoverflow.com/a/54996207/4508758.");
      print("--- 2. Go to the file flutter_app/lib/core/domain/services/notifications_service.dart");
      print("--- 3. Replace the value of _vapidKeyForWeb with your own vapidKey");
      print("-------------------------------------------------------------------------");
    }

    final token = await messaging.getToken(vapidKey: _vapidKeyForWeb);
    return usersDs.updateFcmTokenForLoggedUser(fcmToken: token);
  }

  Future<void> removeTokenFromLoggedUser () {
    return usersDs.updateFcmTokenForLoggedUser(fcmToken: null);
  }

}

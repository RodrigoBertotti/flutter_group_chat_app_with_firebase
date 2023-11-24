import 'package:collection/collection.dart';
import 'package:flutter_group_chat_app_with_firebase/injection_container.dart';

import '../../../../core/domain/services/auth_service.dart';

class Message {
  final String messageId;
  final String conversationId;
  final String text;
  final DateTime sentAt;
  final bool hasPendingWrites;
  final String senderUid;
  final List<String> pendingReceivement;
  final List<String> pendingRead;
  final Map<String,DateTime> receivedAt;
  final Map<String,DateTime> readAt;
  /// [participants] refers to the uids that can read this message
  final List<String> participants;

  Message({
    required this.messageId,
    required this.conversationId,
    required this.text,
    required this.senderUid,
    required this.participants,
    required this.sentAt,
    this.receivedAt = const {},
    this.readAt = const {},
    required this.hasPendingWrites,
    this.pendingRead = const [],
    this.pendingReceivement = const [],
  }) {
    assert(text.isNotEmpty == true);
  }

  bool get iAmNotTheSender => senderUid != getIt.get<AuthService>().loggedUid;

  bool get iAmTheSender => !iAmNotTheSender;

  bool get isGroup => conversationId.startsWith('group_');

  Map<String, DateTime> _notMeMap(Map<String, DateTime> map) {
    return Map<String, DateTime>.from(map)..removeWhere((key, value) => key == getIt.get<AuthService>().loggedUid);
  }

  /// Returns the [DateTime] regarding the recipient that received it last.
  /// Is null in cases where not all the participants have received the message.
  DateTime? get lastReceivedAt {
    if (_notMeMap(receivedAt).length < participants.length - 1) {
      return null;
    }
    return _notMeMap(receivedAt)
        .values
        .sorted((a, b) => a.compareTo(b))
        .lastOrNull;
  }

  /// Returns the [DateTime] regarding the recipient that read it last.
  /// Is null in cases where not all the participants have read the message.
  DateTime? get lastReadAt {
    if (_notMeMap(readAt).length < participants.length - 1) {
      return null;
    }
    return _notMeMap(readAt)
        .values
        .sorted((a, b) => a.compareTo(b))
        .lastOrNull;
  }

  /// Returns whether all the participants have received the message
  bool get received {
    return lastReceivedAt != null;
  }

  /// Returns whether all the participants have read the message
  bool get read {
    return lastReadAt != null;
  }

  /// Returns whether the logged user received this message before or not
  bool get iReceived {
    assert(senderUid != getIt.get<AuthService>().loggedUid, 'This message was sent by the logged user');
    return receivedAt[getIt.get<AuthService>().loggedUid] != null;
  }

  /// Returns whether the logged user read this message before or not
  bool get iRead {
    assert(senderUid != getIt.get<AuthService>().loggedUid, 'This message was sent by the logged user');
    return readAt[getIt.get<AuthService>().loggedUid] != null;
  }

}

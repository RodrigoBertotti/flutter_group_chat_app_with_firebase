import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/model_utils.dart';
import '../../domain/entities/message.dart';


class MessageFirestoreModel extends Message {
  /// Field names:
  static const String kConversationId = "conversationId";
  static const String kMessageId = "messageId";
  static const String kText = "text";
  static const String kSenderUid = "senderUid";
  static const String kParticipants = "participants";
  static const String kReceivedAt = "receivedAt";
  static const String kReadAt = "readAt";
  static const String kSentAt = "sentAt";
  static const String kPendingRead = "pendingRead";
  static const String kPendingReceivement = "pendingReceivement";


  MessageFirestoreModel({required String conversationId,  List<String> pendingReceivement = const [],  List<String> pendingRead = const [], required String messageId, required String text, required String senderUid, required dynamic sentAt,
    Map<String, DateTime>? receivedAt, required List<String> participants, Map<String, DateTime>? readAt, bool active = true, bool? hasPendingWrites})
      : super(
        conversationId: conversationId,
        readAt: readAt ?? const {},
        receivedAt: receivedAt ?? const {},
        hasPendingWrites: hasPendingWrites ?? true,
        participants: participants,
        senderUid: senderUid,
        messageId: messageId,
        text: text,
        sentAt: sentAt is FieldValue ? DateTime.now() : sentAt,
        pendingReceivement: pendingReceivement,
        pendingRead: pendingRead,
      ) {
    assert(sentAt == null || sentAt is FieldValue || sentAt is DateTime);
  }

  static MessageFirestoreModel fromMap(map, bool hasPendingWrites) {
    assert(map is Map);
    return MessageFirestoreModel(
      conversationId: map[kConversationId],
      receivedAt: fromMapOfTimestamp(map[kReceivedAt] ?? const {})!,
      readAt: fromMapOfTimestamp(map[kReadAt] ?? const {})!,
      hasPendingWrites: hasPendingWrites,
      messageId: map[kMessageId],
      text: map[kText],
      participants: List.from(map[kParticipants]),
      senderUid: map[kSenderUid],
      sentAt: (map[kSentAt] as Timestamp).toDate(),
      pendingRead: List<String>.from(map[kPendingRead] ?? []),
      pendingReceivement: List<String>.from(map[kPendingReceivement] ?? []),
    );
  }

  MessageFirestoreModel.fromEntity(Message e) : super(
    messageId: e.messageId,
    conversationId: e.conversationId,
    participants: e.participants,
    senderUid: e.senderUid,
    text: e.text,
    readAt: e.readAt,
    receivedAt: e.receivedAt,
    sentAt: e.sentAt,
    hasPendingWrites: e.hasPendingWrites,
    pendingRead: e.pendingRead,
    pendingReceivement: e.pendingReceivement,
  );

  Map<String,dynamic> toMap() {
    assert(participants.isNotEmpty);
    return {
      kMessageId: messageId,
      kConversationId: conversationId,
      kText: text,
      kSentAt: sentAt,
      kSenderUid: senderUid,
      kParticipants: participants,
      kReceivedAt: receivedAt,
      kReadAt: readAt,
      kPendingRead: pendingRead,
      kPendingReceivement: pendingReceivement,
    };
  }

}

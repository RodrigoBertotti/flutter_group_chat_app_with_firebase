import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/conversation.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/user_public.dart';
import 'package:flutter_group_chat_app_with_firebase/injection_container.dart';
import '../../../../core/domain/services/auth_service.dart';
import 'message.dart';
import 'package:collection/collection.dart';

class DetailedConversation {
  final List<UserPublic> users;
  final List<Message> messages;
  late final Conversation _conversation;

  bool get isGroup => _conversation.isGroup;

  DetailedConversation({required this.users, required this.messages, required Conversation conversation})  {
    _conversation = conversation;
  }

  List<UserPublic> get notMeUsers {
    return users.where((element) => element.uid != getIt.get<AuthService>().loggedUid).toList();
  }

  String? get uidForDirectConversation {
    if (_conversation.isGroup) {
      return null;
    }
    return notMeUsers.firstOrNull?.uid;
  }

  List<UserPublic> get typingUsers => users
      .where((user) => _conversation.typingUids.contains(user.uid))
      .toList();

  String get conversationId => _conversation.conversationId;

  String get title => _conversation.group?.title ?? notMeUsers.firstOrNull?.fullName ?? 'Loading...';
}
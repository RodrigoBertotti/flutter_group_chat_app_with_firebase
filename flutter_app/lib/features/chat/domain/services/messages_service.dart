import 'dart:async';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/auth_service.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/users_service.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/message.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/sending_text_message_entity.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/conversation.dart';
import '../../data/data_sources/messages_ds.dart';

class MessagesService {
  final MessagesDS messagesDatasource;
  final UsersService usersService;
  final AuthService authService;

  MessagesService({required this.messagesDatasource, required this.authService, required this.usersService});

  Stream<Conversation> conversationStream({required String conversationId}) {
    return messagesDatasource.conversationStream(conversationId: conversationId);
  }

  Stream<List<Conversation>> conversationListStream() {
    return messagesDatasource.conversationListStream();
  }

  Future<void> updateImTyping({required String conversationId}) {
    return messagesDatasource.updateImTyping(conversationId: conversationId);
  }

  Future<void> updateMessageToRead({required String conversationId, required String messageId}) {
    return messagesDatasource.updateMessageToRead(conversationId: conversationId, messageId: messageId);
  }

  void newMessage({required SendingMessageEntity message})  {
    messagesDatasource.addMessage(message: message);
  }

  Stream<List<Message>> messagesStream({required String conversationId, int? limitToLast, void Function(List<Message> newReceivedMessageList)? onNewReceivedMessage}) {
    return messagesDatasource.messagesStream(conversationId: conversationId, limit: limitToLast, onNewReceivedMessage: onNewReceivedMessage);
  }

  Stream<int> pendingReadMessagesAmount({required String conversationId}) {
    return messagesDatasource.pendingReadMessagesAmount(conversationId: conversationId);
  }

  Future<String> createConversationIfDoesntExists({required String uidForDirectConversation}) {
    return messagesDatasource.createConversationIfDoesntExists(uidForDirectConversation: uidForDirectConversation);
  }

  Future<Conversation?> getConversationById({required String conversationId}) {
     return messagesDatasource.getConversationById(conversationId: conversationId);
  }

}
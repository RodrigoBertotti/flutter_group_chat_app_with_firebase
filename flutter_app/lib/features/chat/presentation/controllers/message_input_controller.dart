import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/sending_text_message_entity.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/services/messages_service.dart';
import 'package:flutter_group_chat_app_with_firebase/injection_container.dart';

class MessageInputController extends TextEditingController {
  final hasTextToSendNotifier = ValueNotifier<bool>(false);
  final showTextSentIconNotifier = ValueNotifier<bool>(false);
  final String conversationId;
  final List<String> Function() getParticipants;
  final void Function() scrollToBottom;

  String _previousText = "";

  MessageInputController({String? text, required this.conversationId, required this.scrollToBottom, required this.getParticipants}) : super(text: text) {
    addListener(() {
      if (_previousText != this.text && this.text.isNotEmpty) {
        getIt<MessagesService>().updateImTyping(conversationId: conversationId);
      }
      hasTextToSendNotifier.value = this.text.isNotEmpty;
      _previousText = this.text;
    });
  }

  void addMessageToQueue() {
    if (text.isEmpty) {
      log('No text to send');
      return;
    }

    getIt.get<MessagesService>().newMessage(message: SendingMessageEntity(
        conversationId: conversationId,
        text: text,
        participants: getParticipants()
    ));

    clear();
    showTextSentIconNotifier.value = true;
    scrollToBottom();
    Future.delayed(const Duration(seconds: 1), () {
      showTextSentIconNotifier.value = false;
    });
  }
}
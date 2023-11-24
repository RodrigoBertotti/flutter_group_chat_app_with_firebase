import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/scroll_controller.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/auth_service.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/data/utils.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/chat_list_item_entity.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/presentation/controllers/detailed_conversation_controller.dart';
import 'package:flutter_group_chat_app_with_firebase/injection_container.dart';
import 'package:flutter_group_chat_app_with_firebase/main.dart';
import '../../../../screen_routes.dart';
import '../../../groups/presentation/screens/create_group_or_edit_title_screen.dart';
import '../../domain/entities/detailed_conversation.dart';
import '../../domain/services/messages_service.dart';

class RealtimeChatPageController {
  final String conversationId;
  late final DetailedConversationController detailedConversationController;
  final List<String> _userWillReadSoonMessages = [];
  final void Function() scrollToBottom;
  int? _firstEventEmittedAtTimestamp;
  final ScrollController scrollController;
  final ValueNotifier<bool> notifyUnreadMessagesAtTheBottom = ValueNotifier<bool>(false);
  bool _disposed = false;
  Stream<List<ChatListItemEntity>>? _stream;
  
  RealtimeChatPageController({required this.conversationId, required this.scrollToBottom, required this.scrollController}) {
    detailedConversationController = DetailedConversationController(
      conversationId: conversationId,
      onLoad: () {
        if (detailedConversationController.last!.isGroup && detailedConversationController.last!.users.length == 1) {
          Navigator.of(navigatorKey.currentContext!).pushNamed(
              ScreenRoutes.createGroupOrEditTitle,
              arguments: CreateGroupOrEditTitleArgs(editExistingConversationId: conversationId)
          );
        }
      }
    );
    WidgetsBinding.instance.addPostFrameCallback((_) { 
      scrollController.addListener(checkWhetherUserIsReading);
    });
  }

  bool get isGroup => conversationId.startsWith("group_");

  bool get _isReadingLatestMessages => (!_disposed  && _scrollIsCloseToTheBottom && (WidgetsBinding.instance.lifecycleState == null || WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed));
  
  void checkWhetherUserIsReading() {
    if (_isReadingLatestMessages) {
      for (final messageId in _userWillReadSoonMessages) {
        getIt.get<MessagesService>().updateMessageToRead(conversationId: conversationId, messageId: messageId);
      }
      _userWillReadSoonMessages.clear();
      notifyUnreadMessagesAtTheBottom.value = false;
    } else {
      notifyUnreadMessagesAtTheBottom.value = _userWillReadSoonMessages.isNotEmpty;
    }
  }

  void dispose() {
    _disposed = true;
    detailedConversationController.dispose();
  }

  Stream<List<ChatListItemEntity>> streamChatItems() {
    log("streamChatItems called");
    if (_stream != null) {
      return _stream!;
    }

    late final StreamController<List<ChatListItemEntity>> newController;
    late StreamSubscription<DetailedConversation> listening;

    newController = StreamController<List<ChatListItemEntity>>(onCancel: () {
      log("newController onCancel called");
      listening.cancel();
    });

    listening = detailedConversationController.stream.listen((conversation) async {
      final loggedUid = getIt.get<AuthService>().loggedUid;
      for (final pendingReadMessage in conversation.messages.where(
              (element) => element.senderUid != loggedUid && !element.iRead)) {
        if (_isReadingLatestMessages) {
          getIt.get<MessagesService>().updateMessageToRead(
              conversationId: conversationId,
              messageId: pendingReadMessage.messageId
          );
        } else {
          _userWillReadSoonMessages.add(pendingReadMessage.messageId);
        }
      }
      final List<ChatListItemEntity> result = [];
      for (int i = 0; i < conversation.messages.length; i++) {
        final currentMessage = conversation.messages[i];
        final messageBeforeCurrent =
        i == 0 ? null : conversation.messages[i - 1];
        if (messageBeforeCurrent == null ||
            (isDifferentDay(
                currentMessage.sentAt, messageBeforeCurrent.sentAt))) {
          result.add(SeparatorDateForMessages(date: currentMessage.sentAt));
        }
        result.add(MessageChatListItemEntity(message: currentMessage));
      }
      for (final user in conversation.typingUsers) {
        result.add(TypingIndicatorChatListItemEntity(user: user));
      }

      newController.add(result);
      if (_isReadingLatestMessages || (_firstEventEmittedAtTimestamp == null || DateTime.now().millisecondsSinceEpoch - _firstEventEmittedAtTimestamp! < 1000)) {
        _firstEventEmittedAtTimestamp = DateTime.now().millisecondsSinceEpoch;
        notifyUnreadMessagesAtTheBottom.value = false;
        scrollToBottom();
      } else {
        notifyUnreadMessagesAtTheBottom.value = _userWillReadSoonMessages.isNotEmpty;
      }
      _firstEventEmittedAtTimestamp = _firstEventEmittedAtTimestamp! + 1;
    }, onDone: () {
      log("RealtimeChatPageController: closing controller (onClose)");
      if (!newController.isClosed) {
        newController.close();
      }
    });

    return _stream = newController.stream;
  }

  List<String> getParticipants() => detailedConversationController.last?.users.map((e) => e.uid).toList() ?? [];

  bool get _scrollIsCloseToTheBottom => scrollController.position.maxScrollExtent == 0 || (scrollController.position.pixels > 0 && (scrollController.position.maxScrollExtent - scrollController.position.pixels < (MediaQuery.of(navigatorKey.currentContext!).size.height * .1)));
}

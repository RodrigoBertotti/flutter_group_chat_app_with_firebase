import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/chat_list_item_entity.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/presentation/widgets/message_widget.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/presentation/widgets/typing_indicator_widget.dart';
import 'package:flutter_group_chat_app_with_firebase/injection_container.dart';
import '../../../../core/domain/services/auth_service.dart';
import '../../../../core/presentation/widgets/circular_person.dart';
import 'separator_date_for_messages_widget.dart';

class ChatItemWidget extends StatelessWidget {
  final ChatListItemEntity chatItem;
  final bool showSenderInfo;
  final bool extraMarginBeforeSenderInfo;
  final bool isGroup;

  const ChatItemWidget(
      {required this.chatItem,
      Key? key,
      required this.isGroup,
      required this.showSenderInfo,
      required this.extraMarginBeforeSenderInfo})
      : super(key: key);

  String get loggedUid => getIt.get<AuthService>().loggedUid!;

  @override
  Widget build(BuildContext context) {
    if (chatItem is SeparatorDateForMessages) {
      return SeparatorDateForMessagesWidget(
        dateTime: (chatItem as SeparatorDateForMessages).date,
      );
    }
    if (chatItem is! MessageChatListItemEntity &&
        chatItem is! TypingIndicatorChatListItemEntity) {
      throw "TODO: ${chatItem.toString()}";
    }
    return Padding(
      padding: extraMarginBeforeSenderInfo
          ? const EdgeInsets.only(top: 8)
          : EdgeInsets.zero,
      child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isGroup)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Opacity(
                  opacity: showSenderInfo ? 1 : 0,
                  child: const CircularPerson(size: 23),
                ),
              ),
            if (chatItem is MessageChatListItemEntity)
              Expanded(child: MessageSideWidget(
                showSenderInfo: showSenderInfo,
                message: (chatItem as MessageChatListItemEntity).message,
                key: ValueKey((chatItem as MessageChatListItemEntity).message.messageId),
              )),
            if (chatItem is TypingIndicatorChatListItemEntity)
              TypingIndicatorWidget(
                  margin: showSenderInfo ? const EdgeInsets.only(top: 7) : EdgeInsets.zero,
                  showUserInfo: showSenderInfo ? (chatItem as TypingIndicatorChatListItemEntity).user : null,
              ),
          ]
      ),
    );
  }
}

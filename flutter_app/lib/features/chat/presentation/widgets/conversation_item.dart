

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/entities/user_public.dart';
import '../../../../core/domain/services/auth_service.dart';
import '../../../../core/presentation/confirmation_modal.dart';
import '../../../../core/presentation/widgets/person_icon.dart';
import '../../../../injection_container.dart';
import '../../../../screen_routes.dart';
import '../../domain/entities/message.dart';
import '../../domain/services/messages_service.dart';
import '../screens/realtime_chat_screen/realtime_chat_screen.dart';
import 'message_status_widget.dart';

class ConversationItem extends StatelessWidget {
  final String title;
  final String? conversationId;
  final String? uidForDirectConversation;
  final List<UserPublic> typingUsers;
  final Message? lastMessage;
  String get loggedUid => getIt.get<AuthService>().loggedUid!;
  bool get isLeftSide => lastMessage?.senderUid != loggedUid;
  final void Function()? onTap;
  final bool selected;
  final void Function()? removeConversationCallback;
  final bool isGroup;

  const ConversationItem({required this.title, this.isGroup = false, this.selected = false, this.removeConversationCallback, this.onTap, this.lastMessage, this.conversationId, this.uidForDirectConversation, this.typingUsers = const [], Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: borderRadius,
      child: Dismissible(
          key: Key(uidForDirectConversation ?? conversationId ?? title),
          direction: removeConversationCallback != null ? DismissDirection.endToStart : DismissDirection.none,
          confirmDismiss: (_) {
            return showConfirmationModal(context: context, message: isGroup ? "You will leave $title" : "This conversation will be deleted", confirmButtonText: isGroup ? "EXIT GROUP" : "DELETE")
                .then((confirmed) {
              if (confirmed) {
                removeConversationCallback!();
              }
            });
          },
          background: Container(
            clipBehavior: Clip.none,
            decoration: BoxDecoration(color: Colors.red,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isGroup ? Icons.exit_to_app_rounded : Icons.delete_outline, color: Colors.white),
                      Text(isGroup ? "Exit group" : "Delete for me", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),),
                    ],
                  ),
                )
              ],
            ),
          ),
          child: InkWell(
            onTap: onTap ?? () {
              assert(conversationId != null, 'Please, provide onTap');
              Navigator.of(context).pushNamed(ScreenRoutes.chat, arguments: RealtimeChatScreenArgs(conversationId: conversationId!, uidForDirectConversation: uidForDirectConversation));
            },
            child: Ink(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[900]!.withOpacity(.45),
                          border: !selected ? null : Border.all(width: 4, color: Colors.indigo[900]!)
                      ),
                      padding: const EdgeInsets.only(top: 12, right: 18, left: 18, bottom: 6),
                      child: Column(
                        children: [
                          StreamBuilder<int>(
                            stream: conversationId == null || lastMessage == null ? Stream.value(0) : getIt.get<MessagesService>().pendingReadMessagesAmount(conversationId: conversationId!),
                            initialData: 0,
                            builder: (context, pendingReadMessagesAmountSnapshot) {
                              final hasPendingMessages = (pendingReadMessagesAmountSnapshot.data ?? 0) > 0;

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  PersonIcon(isGroup: isGroup,),
                                  const SizedBox(width: 10,),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child:  Text(title, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: hasPendingMessages ? FontWeight.w700 : FontWeight.w600, fontSize: 18, color: Colors.white))),
                                            if(lastMessage?.hasPendingWrites == false)
                                              Text(DateFormat('HH:mm').format(lastMessage!.sentAt), style: TextStyle(color: Colors.white , fontSize: 12, fontWeight: hasPendingMessages ? FontWeight.w800 : FontWeight.w600),)
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            if (lastMessage?.text.isNotEmpty == true && !typingUsers.isNotEmpty)
                                              ...[
                                                if (lastMessage!.senderUid == loggedUid)
                                                  Padding(
                                                      padding: const EdgeInsets.only(right: 6),
                                                      child: MessageStatusWidget(message: lastMessage!)
                                                  ),
                                                Expanded(
                                                  child: Text(lastMessage!.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: hasPendingMessages ? FontWeight.w800 : FontWeight.w600)),
                                                ),
                                              ],
                                            if(typingUsers.isNotEmpty)
                                              Expanded(
                                                child: Text(_formattedTypingMessage(typingUsers), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xff00eb1f))),
                                              ),
                                            if(hasPendingMessages && lastMessage != null)
                                              Builder(
                                                builder: (context) {
                                                  const double kSize = 23;
                                                  return Container(
                                                    width: kSize,
                                                    height: kSize,
                                                    margin: const EdgeInsets.only(left: 3),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xff08c239),
                                                      borderRadius: BorderRadius.circular(kSize / 2),
                                                    ),
                                                    child: Center(
                                                      child: Text(((pendingReadMessagesAmountSnapshot.data ?? 0) > 9 ? '+9' : (pendingReadMessagesAmountSnapshot.data ?? 0).toString()), style: const TextStyle(color: Colors.white, fontSize: 0.6*kSize, fontWeight: FontWeight.w900)),
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 7,),
                        ],
                      ),
                    ),
                    if (selected)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.indigo[900],
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 3),
                            child: Text("selected", style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                  ],
                )
            ),
          )
      ),
    );
  }

  String _formattedTypingMessage(List<UserPublic> typingUsers) {
    String names = typingUsers.map((e) => e.firstName).join(', ');
    bool are = false;
    if (names.contains(', ')) {
      are = true;
      names = names.replaceRange(names.lastIndexOf(','), null, ' and');
    }
    return are ? '$names are typing...' : '$names is typing...';
  }
}
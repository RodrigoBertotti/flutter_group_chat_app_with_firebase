import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/users_service.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/message.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/presentation/widgets/message_status_widget.dart';
import 'package:flutter_group_chat_app_with_firebase/injection_container.dart';
import 'package:intl/intl.dart';
import '../../../../core/domain/entities/user_public.dart';
import '../../../../core/domain/services/auth_service.dart';
import 'balloon_widget.dart';

class MessageSideWidget extends StatelessWidget {
  final Message message;
  final bool showSenderInfo;

  String get loggedUid => getIt.get<AuthService>().loggedUid!;
  bool get isLeftSide => message.senderUid != loggedUid;

  const MessageSideWidget({super.key, required this.message, required this.showSenderInfo});

  @override
  Widget build(BuildContext context) {
    return BalloonWidget(
      isLeftSide: isLeftSide,
      showCurve: !isLeftSide || showSenderInfo || !message.isGroup,
      centerChildConstraints: (currentConstraints) => BoxConstraints(
        minWidth: 0,
        maxWidth: currentConstraints.maxWidth * .43,
      ),
      centerChild: LayoutBuilder(
        builder: (context, constraints) {
          return IntrinsicWidth(
            child: Column (
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLeftSide && message.isGroup && showSenderInfo)
                  StreamBuilder<UserPublic>(
                      stream: getIt.get<UsersService>().streamPublicUser(uid: message.senderUid),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        return Text(snapshot.data!.fullName, style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w600));
                      }
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(message.text.isNotEmpty == true)
                      ...[
                        Flexible(
                          child: Text(message.text, style: TextStyle(fontSize: 15, color: !isLeftSide ? Colors.white : Colors.indigo)),
                        ),
                        SizedBox(
                          width: 28,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: MessageStatusWidget(message: message)
                            ),
                          ),
                        ),
                      ]
                  ],
                ),
                if (message.iAmNotTheSender || !message.hasPendingWrites)
                  ...[
                    const SizedBox(height: 2,),
                    Row(
                      children: [
                        Expanded(child: Container()),
                        Text(DateFormat('HH:mm').format(message.sentAt), style: TextStyle(color: isLeftSide ? Colors.grey[500] : Colors.green[50], fontSize: 10, fontWeight: FontWeight.w500),),
                      ],
                    ),
                  ],
                if (message.hasPendingWrites)
                  const SizedBox(height: 2,)
              ],
            ),
          );
        },
      ),
    );
  }
}


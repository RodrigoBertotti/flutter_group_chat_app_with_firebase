import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/message.dart';
import '../../../../core/domain/services/auth_service.dart';
import '../../../../injection_container.dart';
import 'delay_animate_switcher.dart';

class MessageStatusWidget extends StatelessWidget {
  final Message message;
  get checkIcon => Icon(Icons.check, size: 16, color: message.read ? Colors.blue[300] : Colors.green[50]);

  String get loggedUid => getIt.get<AuthService>().loggedUid!;
  bool get isLeftSide => message.senderUid != loggedUid;

  const MessageStatusWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isLeftSide && message.hasPendingWrites)
          Icon(Icons.access_time_outlined, color: Colors.green[50], size: 17),
        if(!isLeftSide && (!message.hasPendingWrites || message.received || message.read))
          SizedBox(
            width: message.received || message.read ? 25 : null,
            child: Stack(
              children: [
                DelayAnimateSwitcher(
                  firstChild: Container(width: 18,),
                  secondChild: checkIcon,
                  animate: !message.received ? false : (DateTime.now().millisecondsSinceEpoch - 1000 < message.lastReceivedAt!.millisecondsSinceEpoch),
                ),
                if (message.received || message.read)
                  Align(
                    alignment: const Alignment(.85,0),
                    child: DelayAnimateSwitcher(
                        firstChild: Container(width: 18,),
                        secondChild: checkIcon,
                        animate: DateTime.now().millisecondsSinceEpoch - 1000 < message.sentAt.millisecondsSinceEpoch,
                        delay: const Duration(milliseconds: 320)
                    ),
                  )
              ],
            ),
          )
      ],
    );
  }
}

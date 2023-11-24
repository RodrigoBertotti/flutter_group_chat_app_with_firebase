import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/auth_service.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/notifications_service.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/users_service.dart';
import 'package:flutter_group_chat_app_with_firebase/environment.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/services/messages_service.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/presentation/controllers/realtime_chat_page_controller.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/presentation/controllers/message_input_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/chat_list_item_entity.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/presentation/widgets/chat_item_widget.dart';
import 'package:flutter_group_chat_app_with_firebase/features/groups/presentation/screens/create_group_or_edit_title_screen.dart';
import 'package:flutter_group_chat_app_with_firebase/injection_container.dart';
import 'package:flutter_group_chat_app_with_firebase/main.dart';
import 'package:flutter_group_chat_app_with_firebase/screen_routes.dart';
import '../../../../../core/presentation/widgets/center_content_widget.dart';
import '../../../../../core/presentation/widgets/my_appbar_widget.dart';
import '../../../../../core/presentation/widgets/my_multiline_text_field.dart';
import '../../../../../core/presentation/widgets/my_scaffold.dart';
import '../../../../call/presentation/screens/call_screen.dart';
import '../../widgets/typing_indicator_widget.dart';

class RealtimeChatScreenArgs {
  String conversationId;
  String? uidForDirectConversation;
  RealtimeChatScreenArgs({required this.conversationId, this.uidForDirectConversation});
}

class RealtimeChatScreen extends StatefulWidget {
  static const String route = '/chat';

  const RealtimeChatScreen({super.key});

  @override
  State<RealtimeChatScreen> createState() => _RealtimeChatScreenState();
}

class _RealtimeChatScreenState extends State<RealtimeChatScreen> with WidgetsBindingObserver {
  late final MessageInputController addMessageToQueueController;
  final ScrollController scrollController = ScrollController();
  late final RealtimeChatPageController messagesController;
  late final RealtimeChatScreenArgs args;
  bool initialized = false;
  bool loading = true;

  @override
  void didChangeDependencies() {
    if (initialized) {
      print("args already initialized");
      return;
    }
    assert(ModalRoute.of(context)!.settings.arguments != null, "Please, inform the arguments. More info on https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments#4-navigate-to-the-widget");
    args = ModalRoute.of(context)!.settings.arguments as RealtimeChatScreenArgs;

    void init() {
      messagesController = RealtimeChatPageController(conversationId: args.conversationId, scrollToBottom: scrollToBottom, scrollController: scrollController);
      addMessageToQueueController = MessageInputController(text: '', scrollToBottom: scrollToBottom, conversationId: args.conversationId, getParticipants: () => messagesController.getParticipants());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messagesController.checkWhetherUserIsReading();
      });

      initialized = true;
      loading = false;
      getIt.get<NotificationsService>().ignoreNotificationsForConversationId(conversationId: args.conversationId);
    }

    if (args.uidForDirectConversation != null) {
      setState(() {
        loading = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getIt.get<MessagesService>().createConversationIfDoesntExists(uidForDirectConversation: args.uidForDirectConversation!)
          .then((conversationId) {
            args.conversationId = conversationId;
            setState(() {
              init();
              loading = false;
            });
          });
      });
    } else {
      setState(() {
        init();
        loading = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (initialized) {
      messagesController.checkWhetherUserIsReading();
    }
  }

  @override
  void dispose() {
    messagesController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    getIt.get<NotificationsService>().ignoreNotificationsForConversationId(conversationId: null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        background: background2Colors,
        appBar: MyAppBarWidget(
          withBackground: true,
          context: context,
          child: loading
              ? Container()
              : FutureBuilder(
            future: getIt.get<MessagesService>().getConversationById(conversationId: args.conversationId),
            builder: (context, conversationSnapshot) {
              if (conversationSnapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }

              return FutureBuilder(
                  future: conversationSnapshot.data!.isGroup
                      ? Future.value(null)
                      : getIt.get<UsersService>().getUser(uid: conversationSnapshot.data!.participants.firstWhere((uid) => uid != getIt.get<AuthService>().loggedUid)),
                  builder: (context, userForDirectConversationSnapshot) {
                    if (userForDirectConversationSnapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }
                    final String title = conversationSnapshot.data!.group?.title ?? userForDirectConversationSnapshot.data!.fullName;

                    return Center(
                      child: InkWell(
                        onTap: !conversationSnapshot.data!.isGroup ? null : () {
                          if (!conversationSnapshot.data!.group!.adminUids.contains(getIt.get<AuthService>().loggedUid)) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 5),
                              content: Row( //regras para admins
                                children: [
                                  Icon(Icons.warning, color: Colors.white),
                                  SizedBox(width: 5,),
                                  Text('Only Admins can edit group settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ));
                            return;
                          }
                          Navigator.of(context).pushNamed(ScreenRoutes.createGroupOrEditTitle, arguments: CreateGroupOrEditTitleArgs(editExistingConversationId: args.conversationId))
                            .then((_) {
                                setState(() {});
                            });
                        },
                        child: Ink(
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(conversationSnapshot.data!.isGroup ? Icons.group : Icons.person, size: 23, color: Colors.white),
                                    const SizedBox(width: 8,),
                                    Flexible(
                                      child: Text(title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: conversationSnapshot.data!.isGroup ? FontWeight.w800 : FontWeight.w600,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!kIsWeb && Environment.agoraAppId.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _StartCallIcon(conversationId: args.conversationId, iconData: Icons.video_call_rounded),
                                  ],
                                )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
              );
            },
          ),
        ),
        body: Container(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: loading ? [] : [
                  Expanded(
                    child: StreamBuilder<List<ChatListItemEntity>>(
                        stream: messagesController.streamChatItems(),
                        builder: (context, snapshot) {
                          return Stack(
                            children: [
                              ListView.builder(
                                clipBehavior: Clip.none,
                                controller: scrollController,
                                itemCount: snapshot.data?.length ?? 0,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    child: Padding(
                                      padding: index < snapshot.data!.length - 1
                                          ? EdgeInsets.zero
                                          : const EdgeInsets.only(bottom: 15),
                                      child: ChatItemWidget(
                                        key: ValueKey(index),
                                        chatItem: snapshot.data![index],
                                        showSenderInfo: showSenderInfo(snapshot.data!, index),
                                        extraMarginBeforeSenderInfo: extraMarginBeforeSenderInfo(snapshot.data!, index),
                                        isGroup: messagesController.isGroup,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 15,
                                right: 0,
                                child: ValueListenableBuilder(
                                  valueListenable: messagesController.notifyUnreadMessagesAtTheBottom,
                                  builder: (context, unreadMessagesAtTheBottom, _) {
                                    return AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 280),
                                        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child,),
                                        child: !unreadMessagesAtTheBottom
                                            ? Container(key: const Key('hide_go_to_bottom'),)
                                            :  InkWell(
                                          key: const Key('show_go_to_bottom'),
                                          onTap: scrollToBottom,
                                          child: Ink(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.green[500],
                                                      borderRadius: BorderRadius.circular(20)
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                                    child: Text("New messages", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(left: 3),
                                                  decoration: BoxDecoration(color: Colors.green[500], borderRadius: BorderRadius.all(Radius.circular(100))),
                                                  padding: EdgeInsets.all(3),
                                                  child: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 21),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                    );
                                  },
                                ),
                              ),
                              if (loading || snapshot.connectionState == ConnectionState.waiting)
                                const Center(
                                  child: CircularProgressIndicator(color: Colors.indigo),
                                )
                            ],
                          );
                        }),
                  ),

                  Align(
                    alignment: const Alignment(0, 1),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: ValueListenableBuilder(
                        valueListenable: addMessageToQueueController.showTextSentIconNotifier,
                        builder: (context, showTextSentIcon, _) => ValueListenableBuilder<bool>(
                          valueListenable: addMessageToQueueController.hasTextToSendNotifier,
                          builder: (context, hasTextToSend, _) {
                            return MyMultilineTextField(
                              controller: addMessageToQueueController,
                              hintText: 'Type your message here...',
                              onSubmitted: loading ? null : (text) {
                                addMessageToQueueController.addMessageToQueue();
                              },
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8, left: 2),
                                child: _AnimatedSuffixIconForMessage(
                                    sendEnabled: hasTextToSend,
                                    showTextSentIcon: showTextSentIcon,
                                    addMessageToQueue: loading ? null : addMessageToQueueController.addMessageToQueue
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              )
          ),
        )
    );
  }

  String? get loggedUid => getIt.get<AuthService>().loggedUid;

  bool sentByLoggedUser(ChatListItemEntity data) => (data is MessageChatListItemEntity && data.message.senderUid == loggedUid) && data is! TypingIndicatorWidget;

  void scrollToBottom() {
    for (int i=0;i<=12;i++){
      Future.delayed(Duration(milliseconds: i * 50), (){
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  bool showSenderInfo(List<ChatListItemEntity> list, int index) {
    if (!messagesController.isGroup) {
      return false;
    }
    if (list[index] is! MessageChatListItemEntity && list[index] is! TypingIndicatorChatListItemEntity) {
      return false;
    }
    if (list[index] is MessageChatListItemEntity && (list[index] as MessageChatListItemEntity).message.senderUid == loggedUid) {
      return false;
    }
    if (index == 0) {
      return true;
    }
    if (list[index-1] is! MessageChatListItemEntity) {
      return true;
    }
    if (list[index] is TypingIndicatorChatListItemEntity) {
      return (list[index-1] as MessageChatListItemEntity).message.senderUid != (list[index] as TypingIndicatorChatListItemEntity).user.uid;
    }
    if (list[index] is MessageChatListItemEntity && (list[index] as MessageChatListItemEntity).message.senderUid == loggedUid) {
      return false;
    }
    return (list[index-1] as MessageChatListItemEntity).message.senderUid != (list[index] as MessageChatListItemEntity).message.senderUid;
  }

  bool extraMarginBeforeSenderInfo(List<ChatListItemEntity> list, int index) {
    if (!showSenderInfo(list, index)){
      return false;
    }
    return index > 0 && list[index-1] is MessageChatListItemEntity;
  }
}

class _AnimatedSuffixIconForMessage extends StatelessWidget {
  final void Function()? addMessageToQueue;
  final bool sendEnabled;
  final bool showTextSentIcon;

  const _AnimatedSuffixIconForMessage(
      {required this.showTextSentIcon,
      required this.sendEnabled,
      this.addMessageToQueue,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kIconSize,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: () {
          if (showTextSentIcon) {
            return const Icon(
              // Icons.input_rounded,
              // Icons.mail_rounded,
              // Icons.near_me_rounded,
              Icons.outbond_rounded,
              color: Colors.white,
              size: kIconSize,
            );
            // return const Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.indigo, size: kIconSize,);
          }
          if (!sendEnabled) {
            return const SizedBox();
          }
          return InkWell(
              onTap: addMessageToQueue,
              child: Ink(
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: kIconSize,
                ),
              ));
        }(),
      ),
    );
  }
}

class _StartCallIcon extends StatelessWidget {
  final String conversationId;
  final IconData iconData;

  const _StartCallIcon({required this.conversationId, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(ScreenRoutes.call,
            arguments: CallScreenArgs(conversationId: conversationId,)
        );
      },
      child: Ink(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Icon(iconData, size: 23, color: Colors.white),
        ),
      ),
    );
  }
}


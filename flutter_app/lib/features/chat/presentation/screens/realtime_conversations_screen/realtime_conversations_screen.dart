import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/core/presentation/confirmation_modal.dart';
import 'package:flutter_group_chat_app_with_firebase/core/presentation/widgets/center_content_widget.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/detailed_conversation.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/message.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/user_public.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/services/messages_service.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/presentation/controllers/users_to_talk_to_controller.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/presentation/screens/realtime_chat_screen/realtime_chat_screen.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/presentation/widgets/message_status_widget.dart';
import 'package:flutter_group_chat_app_with_firebase/features/groups/presentation/screens/create_group_or_edit_title_screen.dart';
import 'package:flutter_group_chat_app_with_firebase/injection_container.dart';
import 'package:flutter_group_chat_app_with_firebase/main.dart';
import 'package:flutter_group_chat_app_with_firebase/screen_routes.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../../core/domain/services/auth_service.dart';
import '../../../../../core/presentation/widgets/button_widget.dart';
import '../../../../../core/presentation/widgets/expanded_section_widget.dart';
import '../../../../../core/presentation/widgets/my_appbar_widget.dart';
import '../../../../../core/presentation/widgets/my_multiline_text_field.dart';
import '../../../../../core/presentation/widgets/my_scaffold.dart';
import '../../../../../core/presentation/widgets/person_icon.dart';
import '../../controllers/detailed_conversation_list_controller.dart';
import 'dart:math' as math;

import '../../controllers/signout_controller.dart';
import '../../widgets/conversation_item.dart';
import '../../widgets/logout_button_widget.dart';

class RealtimeConversationsScreen extends StatefulWidget {
  static const String route = '/conversations';

  const RealtimeConversationsScreen({Key? key}) : super(key: key);

  @override
  State<RealtimeConversationsScreen> createState() => _RealtimeConversationsScreenState();

}

class _RealtimeConversationsScreenState extends State<RealtimeConversationsScreen> {
  final detailedConversationsController = DetailedConversationListController(messagesLimitForEachConversation: 1);
  final TextEditingController searchController = TextEditingController();
  final signOutController = SignOutController();

  _RealtimeConversationsScreenState() : super();

  bool startedConversationsIsExpanded = true;
  bool allContactsIsExpanded = true;

  final usersToTalkToController = UsersToTalkToController();

  void _clearText() {
    setState(() {
      searchController.text = '';
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchController.addListener(() {
        setState(() {
          startedConversationsIsExpanded = allContactsIsExpanded = true;
        });
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    detailedConversationsController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // final double contentHeight = MediaQuery.of(context).size.height - 82;
    final double contentHeight = MediaQuery.of(context).size.height - 105;


    return MyScaffold(
      background: background2Colors,
      appBar: MyAppBarWidget(
        context: context,
        withBackground: true,
        // child: Text('Conversations', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kPageContentWidth),
          child: Row(
            children: [
              Expanded(
                child:  MyMultilineTextField(
                  hintText: 'Search for conversations',
                  controller: searchController,
                  fillColor: Colors.blue[800],
                  maxLines: 1,
                  suffixIcon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: searchController.text.isEmpty
                        ? Icon(Icons.search_rounded, color: Colors.blue[900]!, size: 27)
                        : InkWell(
                      onTap: _clearText,
                      child: Ink(
                        child: const Icon(Icons.clear_rounded, color: Colors.white, size: 27,),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10,),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: SignOutButtonWidget(),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(height: contentHeight, width: MediaQuery.of(context).size.width,),
          SingleChildScrollView(
            clipBehavior: Clip.none,
            child: Column(
              children: [
                StreamBuilder(
                  stream: detailedConversationsController.stream,
                  builder: (context, conversationsSnapshot) {
                    if(conversationsSnapshot.hasError){
                      log("An error occurred on ListenToConversationsWithMessages: ${conversationsSnapshot.error ?? "null"}");
                      return Container();
                    }
                    if(!conversationsSnapshot.hasData || conversationsSnapshot.data!.isEmpty){
                      return Container();
                    }
                    final conversations = filteredConversations(conversationsSnapshot.data!);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Subtitle(title: 'Conversations (${conversations.length.toString()})', isExpanded: startedConversationsIsExpanded, toggleExpand: (expand){setState(() {startedConversationsIsExpanded = expand;});}),
                        ExpandedSection(
                          expand: startedConversationsIsExpanded,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7, bottom: 10),
                            child: Column(
                              children: conversations.mapIndexed((index, conversation) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: ConversationItem(
                                  conversationId: conversation.conversationId,
                                  isGroup: conversation.isGroup,
                                  uidForDirectConversation: conversation.uidForDirectConversation,
                                  title: conversation.title,
                                  lastMessage: conversation.messages.lastOrNull,
                                  typingUsers: conversation.typingUsers,
                                  removeConversationCallback: () {
                                    detailedConversationsController.exitConversation(conversationId: conversation.conversationId);
                                  },
                                ),
                              )).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (!startedConversationsIsExpanded)
                  const SizedBox(height: 15,),
                StreamBuilder(
                  stream: usersToTalkToController.stream(),
                  builder: (context, snapshotContacts) {
                    if(snapshotContacts.hasError){
                      log("An error occurred on FutureBuilder ReadAllContacts: ${snapshotContacts.error ?? "null"} ${snapshotContacts.data ?? "null"}");
                      return SizedBox(
                        height: contentHeight,
                        child: const Center(child: Text("An error occurred. Please try again later", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),),
                      );
                    }
                    if(!snapshotContacts.hasData){
                      return SizedBox(
                        height: contentHeight,
                        child: Center(child: CircularProgressIndicator(color: Colors.blue[100],),),
                      );
                    }
                    final contacts = snapshotContacts.data!
                        .where((element) => ("${element.firstName} ${element.lastName}").toLowerCase().contains(searchController.text.toLowerCase()));

                    if(contacts.isEmpty && !detailedConversationsController.hasData){
                      return SizedBox(
                          height: contentHeight,
                          child: Column(
                            mainAxisAlignment: searchController.text.isEmpty
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            children: [
                              Icon(Icons.supervised_user_circle, color: Colors.white.withOpacity(.5), size: 80),
                              SizedBox(height: 10,),
                              const Text("No conversation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18), textAlign: TextAlign.center,),
                              const SizedBox(height: 10,),
                              Text(searchController.text.isEmpty
                                  ? "Create another account and start playing :)"
                                  : "No conversation matches the filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15), textAlign: TextAlign.center,),
                              const SizedBox(height: 22,),
                              ButtonWidget(text: 'LOGOUT', isSmall: true, width: 150, onPressed: () {
                                signOutController.signOut(context);
                              },)
                            ],
                          )
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Subtitle(title: 'Contacts (${contacts.length.toString()})', isExpanded: allContactsIsExpanded, toggleExpand: (expand){setState(() {allContactsIsExpanded = expand;});}),
                        ExpandedSection(
                          expand: allContactsIsExpanded,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 8,),
                              ...contacts.map((user) => Padding(padding: const EdgeInsets.symmetric(vertical: 8,), child:  ConversationItem(conversationId: user.conversationId, title: user.fullName, uidForDirectConversation: user.uid,),)).toList(),
                              const SizedBox(height: 18,),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder(
          stream: usersToTalkToController.stream(),
          builder: (context, snapshot) {
            return Padding(
              padding: EdgeInsets.only(right: math.max(0, (MediaQuery.of(context).size.width - kPageContentWidth) / 2)),
              child: Visibility(
                visible: snapshot.data?.isNotEmpty == true,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).pushNamed(ScreenRoutes.createGroupOrEditTitle, arguments: CreateGroupOrEditTitleArgs());
                  },
                  backgroundColor: Colors.indigo[900],
                  label: const Text("Create Group", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  icon: const Icon(Icons.group, color: Colors.white),
                ),
              ),
            );
          }
      ),
    );
  }

  List<DetailedConversation> filteredConversations(List<DetailedConversation> conversations) {
    String _unformat(String? text) => (text ?? '').toLowerCase().replaceAll(' ', '');

    return conversations
        .where((element) => _unformat(element.messages.lastOrNull?.text).contains(_unformat(searchController.text)) == true
            || _unformat(element.title).contains(_unformat(searchController.text))
            || element.users.length <= 1
            || element.users.any((user) => _unformat(user.fullName).contains(_unformat(searchController.text)))
        ).toList();
  }
}

class _Subtitle extends StatelessWidget {
  final String title;
  final ValueChanged<bool> toggleExpand;
  final bool isExpanded;

  const _Subtitle({Key? key, required this.title, required this.toggleExpand, required this.isExpanded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: InkWell(
        onTap: () => toggleExpand(!isExpanded),
        child: Ink(
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(isExpanded ? 'HIDE' : 'SHOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                    Icon(isExpanded ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined , color: Colors.white, size: 22,),
                    const SizedBox(width: 7,),
                    Expanded(child: Container(height: 1, color: Colors.blue[100],)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 2),
                child: Text(title, style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              Expanded(child: Container(height: 1, color: Colors.blue[100],)),
            ],
          ),
        ),
      ),
    );
  }
}

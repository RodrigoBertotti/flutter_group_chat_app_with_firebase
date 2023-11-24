import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/auth_service.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/conversation.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/services/messages_service.dart';
import 'package:flutter_group_chat_app_with_firebase/features/groups/domain/services/groups_service.dart';
import 'package:flutter_group_chat_app_with_firebase/injection_container.dart';
import '../../domain/entities/detailed_conversation.dart';
import 'detailed_conversation_controller.dart';


class DetailedConversationListController {
  final int? messagesLimitForEachConversation;
  late final StreamController<List<DetailedConversation>> _streamController;
  Map<String,DetailedConversationController> _detailedCtrlByConversationId = {};
  Map<String,DetailedConversation> _detailedConversationByConversationId = {};
  bool cancelled = false;
  StreamSubscription<List<Conversation>>? _conversationsSubscription;

  List<DetailedConversation> _sortedConversations () => _detailedConversationByConversationId.values.sorted((a,b) {
    if (a.messages.isEmpty) {
      return 1;
    }
    if (b.messages.isEmpty) {
      return -1;
    }
    return a.messages.last.sentAt.compareTo(b.messages.last.sentAt) * -1;
  });

  void _emit () {
    _streamController.add(_sortedConversations());
  }

  bool get hasData => _detailedCtrlByConversationId.values.isNotEmpty;
  bool _initialized = false;
  DetailedConversationListController({this.messagesLimitForEachConversation}) {
    _streamController = StreamController<List<DetailedConversation>>.broadcast(onListen: () {
      if (_initialized) {
        print("ignoring multiple initializations");
        return;
      }
      _initialized = true;
      _conversationsSubscription = getIt.get<MessagesService>()
          .conversationListStream()
          .listen((remoteConversations) async {
            for (final conversation in remoteConversations) {
              if (_detailedCtrlByConversationId[conversation.conversationId] == null) {
                _detailedCtrlByConversationId[conversation.conversationId] = DetailedConversationController(conversationId: conversation.conversationId, messagesLimit: messagesLimitForEachConversation);
                _detailedCtrlByConversationId[conversation.conversationId]!.stream.listen((detailedConversation) {
                  _detailedConversationByConversationId[conversation.conversationId] = detailedConversation;
                  _emit();
                });
              }
            }

            final List<String> deleteLocalConversations = _detailedCtrlByConversationId
                .keys
                .where((localConversationId) => !remoteConversations.any((element) => element.conversationId == localConversationId))
                .toList();


            for (final localConversationId in deleteLocalConversations) {
              print("!!!deleting!!!");
              _detailedCtrlByConversationId[localConversationId]?.dispose();
              _detailedCtrlByConversationId.remove(localConversationId);
              _detailedConversationByConversationId.remove(localConversationId);
            }
            _emit();
          });
    });
  }

  Stream<List<DetailedConversation>> get stream {
    assert(!cancelled, 'The controller is no longer active');
    return _streamController.stream;
  }

  void dispose () {
    print("--------> dispose!");
    _conversationsSubscription?.cancel();
    _streamController.close();
    for (final ctrl in List.from(_detailedCtrlByConversationId.values)) {
      ctrl.dispose();
    }
    _detailedCtrlByConversationId.clear();
  }

  Future<void> exitConversation({required String conversationId}) {
    return getIt.get<GroupsService>().removeParticipant(conversationId: conversationId, uid: getIt.get<AuthService>().loggedUid!);
  }

}
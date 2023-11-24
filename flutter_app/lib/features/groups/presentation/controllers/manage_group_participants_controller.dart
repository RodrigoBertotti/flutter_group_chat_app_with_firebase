import 'dart:async';
import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/user_public.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/auth_service.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/users_service.dart';
import 'package:stream_d/stream_d.dart';
import '../../../../injection_container.dart';
import '../../../chat/domain/entities/conversation.dart';
import '../../domain/services/groups_service.dart';

class ManageGroupParticipantsController {
  late final String _conversationId;
  bool _initialized = false;
  final Map<String, UserPublic> _usersCache = {};
  final StreamController<Conversation> _streamController = StreamController();
  Conversation? _conversation;

  Conversation? get conversation => _conversation;

  ManageGroupParticipantsController();

  String get conversationId => _conversationId;

  bool get iAmAdmin => _conversation!.group!.adminUids.contains(getIt.get<AuthService>().loggedUid);
  
  init ({required String conversationId}) {
    assert(!_initialized);
    _initialized = true;
    _conversationId = conversationId;
    final subscription = StreamD(getIt.get<GroupsService>().readGroupStream(conversationId: conversationId))
        .listenD((event) {
      _conversation = event;
      Future.wait(
          event.participants.map((uid) => Future(() async {
            _usersCache[uid] ??= (await getIt.get<UsersService>().getUser(uid: uid))!;
          })).toList()).then((_) {
        _streamController.add(event);
      });
    });
    _streamController.onCancel = subscription.cancel;
    subscription.addOnDone(() {
      print("manage group participants is done!");
      _streamController.close();
    });
  }

  void dispose () => _streamController.close();

  List<UserPublic> get admins => _conversation!.group!.adminUids.map((uid) => _usersCache[uid]!).toList();
  List<UserPublic> get participants {
    final loggedUid = getIt.get<AuthService>().loggedUid;
    return _conversation!.participants.where((uid) => uid != loggedUid).map((uid) => _usersCache[uid]!).toList();
  }

  Future<void> removeParticipant({required String uid}) {
    return getIt.get<GroupsService>().removeParticipant(conversationId: conversationId, uid: uid);
  }
  
  bool get initialized => _initialized;

  UserPublic user(String uid) => _usersCache[uid]!;

  Stream<Conversation> readGroupStream () {
    return _streamController.stream;
  }

  isAdmin(String uid) => _conversation!.group!.adminUids.contains(uid);

  Future<void> addAdminPrivilege(String uid) {
    return getIt.get<GroupsService>().addAdminPrivilege(conversationId: conversationId, uid: uid);
  }

  Future<void> removeAdminPrivilege(String uid) {
    return getIt.get<GroupsService>().removeAdminPrivilege(conversationId: conversationId, uid: uid);
  }
  
}
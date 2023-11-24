import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/user_public.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/users_service.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/services/messages_service.dart';
import 'package:flutter_group_chat_app_with_firebase/injection_container.dart';
import '../../../chat/domain/entities/conversation.dart';
import '../../domain/services/groups_service.dart';

class AddParticipantsController {
  final String? conversationId;
  bool _initialized = false;
  final ValueNotifier<bool> notifyIsLoading = ValueNotifier<bool>(false);

  final ValueNotifier<Map<String, (UserPublic, bool)>> notifySelectedUsers = ValueNotifier<Map<String, (UserPublic, bool)>>({});
  final Map<String, bool> selectedUsers = {};

  ValueNotifier<bool> notifySuccess = ValueNotifier<bool>(false);
  Conversation? conversation;

  StreamSubscription<List<UserPublic>>? listeningToAllUsersExceptLogged;
  StreamSubscription<Conversation>? listeningToConversation;

  List<UserPublic>? _users;


  AddParticipantsController({this.conversationId});

  bool get initialized => _initialized;

  String get title {
    if (notifyIsLoading.value) {
      return "loading...";
    }
    if (conversation != null) {
      return 'Editing ${conversation!.group!.title}';
    }
    return 'Creating a New Group';
  }


  void initialize() {
    _initialized = true;
    notifyIsLoading.value = true;

    startListeningToConversation(conversationId!);

    listeningToAllUsersExceptLogged = getIt.get<UsersService>()
        .streamAllUsersExceptLogged()
        .listen((List<UserPublic> users) async {
          _users = users;
          _setUsers();
        });
  }

  void dispose() {
    notifyIsLoading.dispose();
    notifySuccess.dispose();
    listeningToAllUsersExceptLogged?.cancel();
    listeningToConversation?.cancel();
  }

  selectUserChanged(String uid, bool selected){
    selectedUsers[uid] = selected;
    _notifySelectedUsers();
  }

  List<UserPublic>? get outsideGroupUsers => _users?.where((user) => !conversation!.participants.contains(user.uid)).toList();

  void _setUsers() {
    print("_setUsers #1");
    if (conversation != null && _users != null) {
      print("_setUsers #2");
      notifyIsLoading.value = true;

      for (final user in outsideGroupUsers!) {
        selectedUsers[user.uid] = selectedUsers[user.uid] ?? false;
      }
      List<String> deleteUids = [];
      for (final uid in selectedUsers.keys) {
        if (!outsideGroupUsers!.any((element) => element.uid == uid)) {
          deleteUids.add(uid);
        }
      }
      for (final uid in deleteUids) {
        selectedUsers.remove(uid);
      }

      _notifySelectedUsers();

      notifyIsLoading.value = false;
    }
  }

  void startListeningToConversation(String conversationId) {
    print("#1 startListeningToConversation: ${conversationId}");
    listeningToConversation = getIt.get<MessagesService>().conversationStream(conversationId: conversationId)
        .listen((conversation) {
      print("#2 startListeningToConversation: ${conversationId}");
      this.conversation = conversation;
      _setUsers();
    });
  }

  void _notifySelectedUsers() { 
    notifySelectedUsers.value = selectedUsers.map((uid, selected) => MapEntry(uid, ((_users!.firstWhere((element) => element.uid == uid)), selected)));
  }

  Future<int> addParticipants() {
    final Completer<int> completer = Completer();
    final entries = selectedUsers.entries.where((element) => element.value).toList();
    int pending = entries.length;
    for (final entry in entries) {
      getIt.get<GroupsService>().addParticipant(conversationId: conversation!.conversationId, uid: entry.key)
        .then((_) {
          pending--;
          if (pending == 0) {
            completer.complete(entries.length);
          }
        });
    }
    selectedUsers.clear();
    return completer.future;
  }

}
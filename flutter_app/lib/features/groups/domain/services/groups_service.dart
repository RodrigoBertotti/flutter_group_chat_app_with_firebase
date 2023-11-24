import 'package:flutter_group_chat_app_with_firebase/core/domain/services/auth_service.dart';
import '../../../chat/domain/entities/conversation.dart';
import '../../data/datasources/groups_ds.dart';


class GroupsService {
  final GroupsDS groupsDS;
  final AuthService authService;

  GroupsService({required this.groupsDS, required this.authService});

  Future<Conversation> createGroup({required String groupTitle}) {
    return groupsDS.createGroup(groupTitle: groupTitle, uids: [authService.loggedUid!], groupAdminUids: [authService.loggedUid!]);
  }

  Future<void> addParticipant({required String conversationId, required String uid, bool isAdmin = false}) {
    return groupsDS.addParticipant(conversationId: conversationId, uid: uid, isAdmin: isAdmin);
  }

  Future<void> removeParticipant({required String conversationId, required String uid}) {
    return groupsDS.removeParticipant(conversationId: conversationId, uid: uid);
  }

  Future<void> editGroupsTitle({required String conversationId, required String groupTitle}) {
    return groupsDS.editGroupsTitle(conversationId: conversationId, groupTitle: groupTitle);
  }

  Stream<Conversation> readGroupStream({required String conversationId}) {
    return groupsDS.readGroupStream(conversationId: conversationId);
  }

  Future<void> addAdminPrivilege({required String conversationId, required String uid}) {
    return groupsDS.addAdminPrivilege(conversationId: conversationId, uid: uid);
  }

  Future<void> removeAdminPrivilege({required String conversationId, required String uid}) {
    return groupsDS.removeAdminPrivilege(conversationId: conversationId, uid: uid);
  }
  
}
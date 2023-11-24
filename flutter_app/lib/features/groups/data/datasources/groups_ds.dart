import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/data/models/conversation_model.dart';
import '../../../../core/domain/services/auth_service.dart';
import '../../../chat/domain/entities/conversation.dart';

class GroupsDS {
  final FirebaseFirestore firestore;
  final AuthService authService;

  GroupsDS({required this.firestore, required this.authService});

  Future<Conversation> createGroup({required String groupTitle, required List<String> uids, List<String>? groupAdminUids}) async {
    assert(authService.loggedUid != null, "current user is not logged in");

    final conversationId = "group_${firestore.collection('_').doc().id}";
    final ref = firestore.collection("conversations").doc(conversationId);
    final data = {
      ConversationModel.kConversationId: conversationId,
      ConversationModel.kParticipants: uids,
      ConversationModel.kGroup: {
        ConversationGroupModel.kTitle: groupTitle,
        ConversationGroupModel.kAdminUids: groupAdminUids ?? [ authService.loggedUid! ],
        ConversationGroupModel.kCreatedBy: authService.loggedUid,
        ConversationGroupModel.kJoinedAt: {
          authService.loggedUid: FieldValue.serverTimestamp(),
        },
      },
    };
    await ref.set(data);
    return ConversationModel.fromData(data, [])!;
  }

  Future<void> addParticipant({required String conversationId, required String uid, bool isAdmin = false}) async {
    final ref = firestore.collection("conversations").doc(conversationId);
    final data = {
      ConversationModel.kParticipants: FieldValue.arrayUnion([uid]),
      "${ConversationModel.kGroup}.${ConversationGroupModel.kJoinedAt}.$uid": FieldValue.serverTimestamp(),
    };
    if (isAdmin) {
      data['${ConversationModel.kGroup}.${ConversationGroupModel.kAdminUids}'] = FieldValue.arrayUnion([uid]);
    }
    await ref.update(data);
  }

  Future<void> removeParticipant({required String conversationId, required String uid}) async {
    final group = conversationId.startsWith('group_') ? {
      '${ConversationModel.kGroup}.${ConversationGroupModel.kJoinedAt}.$uid': FieldValue.delete(),
      '${ConversationModel.kGroup}.${ConversationGroupModel.kAdminUids}.$uid': FieldValue.delete(),
    } : {};
    await firestore.collection("conversations").doc(conversationId).update({
      ConversationModel.kParticipants: FieldValue.arrayRemove([uid]),
      ...group
    });
  }

  Future<void> editGroupsTitle({required String conversationId, required String groupTitle}) async {
    await firestore.collection("conversations").doc(conversationId).update({
      '${ConversationModel.kGroup}.${ConversationGroupModel.kTitle}': groupTitle
    });
  }

  Stream<Conversation> readGroupStream({required String conversationId}) {
    return firestore.collection("conversations").doc(conversationId)
        .snapshots()
        .map((event) => ConversationModel.fromData(event.data())!);
  }

  Future<void> addAdminPrivilege({required String conversationId, required String uid}) {
    return firestore.collection("conversations").doc(conversationId).update({
      '${ConversationModel.kGroup}.${ConversationGroupModel.kAdminUids}': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> removeAdminPrivilege({required String conversationId, required String uid}) {
    return firestore.collection("conversations").doc(conversationId).update({
      '${ConversationModel.kGroup}.${ConversationGroupModel.kAdminUids}': FieldValue.arrayRemove([uid])
    });
  }
}
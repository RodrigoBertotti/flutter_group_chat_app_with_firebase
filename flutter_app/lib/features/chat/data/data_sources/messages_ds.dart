import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/auth_service.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/data/data_sources/typing_ds.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/data/models/conversation_model.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/conversation.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/sending_text_message_entity.dart';
import 'package:flutter_group_chat_app_with_firebase/features/chat/domain/entities/message.dart';
import 'package:stream_d/stream_d.dart';
import '../../../../injection_container.dart';
import '../models/message_firestore_model.dart';
import './../../domain/chat_utils.dart' as chatUtils;


class MessagesDS {
  final AuthService authService;
  final FirebaseFirestore firestore;
  final TypingDS typingDs;
  final List<String> _recentlyCreatedConversations = [];

  MessagesDS({required this.authService, required this.firestore, required this.typingDs}) {
    authService.addOnSignOutListener(() {
      _updatedToReadMessages.clear();
      _updatedToReceivedMessages.clear();
    });
  }

  List<MessageFirestoreModel> _fromMapList (QuerySnapshot<Map<String, dynamic>> event) => List.from(event.docs).map((e) => MessageFirestoreModel.fromMap(e.data(), e.metadata.hasPendingWrites)).toList();

  Future<String> createConversationIfDoesntExists({required String uidForDirectConversation}) async {
    assert(authService.loggedUid != null, "current user is not logged in");

    final conversationId = chatUtils.getDirectConversationId([uidForDirectConversation, getIt.get<AuthService>().loggedUid!]);
    if (_recentlyCreatedConversations.contains(conversationId)) {
      return conversationId;
    }
    final ref = firestore.collection("conversations").doc(conversationId);
    if (!(await ref.get()).exists) {
      await ref.set({
        ConversationModel.kConversationId: conversationId,
        ConversationModel.kParticipants: [getIt.get<AuthService>().loggedUid!, uidForDirectConversation],
      });
    }
    _recentlyCreatedConversations.add(conversationId);
    return ref.id;
  }

  Stream<List<Message>> messagesStream({required String conversationId, int? limit, void Function(List<Message> newReceivedMessageList)? onNewReceivedMessage}) {
    print('messagesStream called at ${DateTime.now().millisecondsSinceEpoch}');
    assert(authService.loggedUid != null, "current user is not logged in");

    late final StreamController<List<MessageFirestoreModel>> ctrl;
    late final StreamSubscriptionD<QuerySnapshot<Map<String, dynamic>>> sub;

    Query<Map<String, dynamic>> query = firestore.collection("conversations").doc(conversationId).collection("messages")
      .where(MessageFirestoreModel.kParticipants, arrayContains: authService.loggedUid!)
      .orderBy(MessageFirestoreModel.kSentAt, descending: false);

    if (limit != null) {
      query = query.limitToLast(limit);
    }

    sub = StreamD(query.snapshots(includeMetadataChanges: true)).listenD((event) {
      print('${event.size} messages received at ${DateTime.now().millisecondsSinceEpoch}');

      Future.delayed(const Duration(seconds: 5), () {
        _updatedToReceivedMessages.removeWhere((element) => element.received && element.receivedAt[authService.loggedUid]!.millisecondsSinceEpoch + (4 * 1000) <= DateTime.now().millisecondsSinceEpoch);
      });

      final List<Message> onNewReceivedMessageList = [];

      for (int i = 0; i < event.size; i++) {
        final message = MessageFirestoreModel.fromMap(
            event.docs[i].data(),
            event.docs[i].metadata.hasPendingWrites);

        if (message.senderUid != authService.loggedUid &&
            !message.iReceived) {
          if (_updatedToReceivedMessages.any((msg) =>
          msg.messageId == message.messageId)) {
            print("ignoring updating message to received again");
            continue;
          }

          _updatedToReceivedMessages.add(message);
          onNewReceivedMessageList.add(message);

          print(
              ">> new message has been received! message.iReceived: ${message
                  .iReceived}");
          event.docs[i].reference.update({
            "${MessageFirestoreModel.kReceivedAt}.${authService
                .loggedUid}": FieldValue.serverTimestamp(),
            MessageFirestoreModel.kPendingReceivement: FieldValue
                .arrayRemove([authService.loggedUid]),
          });

          typingDs.cancelTypingForUid(conversationId: conversationId, uid: message.senderUid);
        }
      }

      ctrl.add(_fromMapList(event));
      if (onNewReceivedMessage != null) {
        onNewReceivedMessage(onNewReceivedMessageList.sorted((a, b) =>
            a.sentAt.compareTo(b.sentAt)).toList());
      }
    });
    ctrl = StreamController<List<MessageFirestoreModel>>(
      onCancel: () {
        Future.delayed(const Duration(milliseconds: 30), () { // delay for firestore
          sub.cancel();
        });
      }
    );

    late void Function() onLoggedOutListener;
    onLoggedOutListener = () {
      print("--> onLoggedOutListener: ${ctrl.isClosed}");
      ctrl.close();
      authService.removeOnSignOutListener(onLoggedOutListener);
    };
    authService.addOnSignOutListener(onLoggedOutListener);

    sub.addOnDone(ctrl.close);

    return ctrl.stream;
  }


  final Set<String> _updatedToReadMessages = {};
  final Set<Message> _updatedToReceivedMessages = {};
  
  Future<void> updateMessageToRead({required String conversationId, required String messageId}) async {
    assert(authService.loggedUid != null, "current user is not logged in");

    if (_updatedToReadMessages.contains(messageId)) {
      print("ignoring updateMessageToRead called twice");
      return;
    }
    _updatedToReadMessages.add(messageId);
    
    return firestore
        .collection("conversations")
        .doc(conversationId)
        .collection("messages")
        .doc(messageId)
        .update({
          "${MessageFirestoreModel.kReadAt}.${authService.loggedUid}": FieldValue.serverTimestamp(),
          MessageFirestoreModel.kPendingRead: FieldValue.arrayRemove([authService.loggedUid]),
        });
  }

  DocumentReference<Map<String,dynamic>> _conversationRef({required String conversationId}) {
    return firestore.collection("conversations").doc(conversationId);
  }

  Future<Conversation?> getConversationById({required String conversationId}) async {
    final snaspshot = await _conversationRef(conversationId: conversationId).get();
    if (!snaspshot.exists) {
      return null;
    }
    Map<String, dynamic>? data = snaspshot.data();
    data ??= (await _conversationRef(conversationId: conversationId).get(const GetOptions(source: Source.server))).data(); // In case the conversation was recently deleted
    return ConversationModel.fromData(data, []);
  }



  Stream<List<Conversation>> conversationListStream () {
    final Map<String, Conversation?> conversations = {};
    final StreamController<List<Conversation>> streamCtrl = StreamController();
    Map<String, RefreshTypingListener> typingListener = {};

    void addEvent () {
      print("addEvent: ");
      final event = conversations.values.where((e) => e != null).map((e) => e!).toList();
      print(event);
      streamCtrl.add(event);
    }

    void closeConversation(String conversationId) {
      if (typingListener[conversationId] != null) {
        typingDs.removeListener(listener: typingListener[conversationId]!);
      }
      typingListener.remove(conversationId);
      conversations.remove(conversationId);
    }

    final subscription = StreamD(
        firestore
            .collection("conversations")
            .where(ConversationModel.kParticipants, arrayContains: authService.loggedUid)
            .snapshots()
    ).listenD((remoteConversations) async {
      // deleting conversations that doesn't exist anymore
      for (final existingConversationId in List.from(conversations.keys)) {
        if (!remoteConversations.docs.any((doc) => doc.id == existingConversationId)) {
          closeConversation(existingConversationId);
        }
      }

      print("remoteConversations.docs -> ${remoteConversations.docs.length}");

      // handling typing events for each conversation
      for (final conversation in remoteConversations.docs) {
        final String conversationId = conversation.id;
        final snapshotData = conversation.data();

        if (typingListener[conversationId] == null) {
          typingListener[conversationId] = typingDs.addListener(
              conversationId: conversationId,
              listener: (typingUids) {
                conversations[conversationId] = ConversationModel.fromData(snapshotData, typingUids);
                addEvent();
                if (conversations[conversationId] == null) {
                  print("looks like conversation \"$conversationId\" has been deleted");
                  closeConversation(conversationId);
                }
              }
          );
        } else {
          conversations[conversationId] = ConversationModel.fromData(snapshotData, conversations[conversationId]?.typingUids ?? []);
        }
      }
      addEvent();
    });

    subscription.addOnDone(() {
      print("onDone subscription (messages)");
      streamCtrl.close();
    });
    streamCtrl.onCancel = () {
      print("streamCtrl.onCancel (messages)");
      for (final conversationId in List.from(conversations.keys)) {
        closeConversation(conversationId);
      }
      subscription.cancel();
    };

    return streamCtrl.stream;
  }
  
  /// Stream that sends a new event every time a new user in the conversation types or stops typing.
  /// It doesn't consider the loggedUid.
  Stream<Conversation> conversationStream({required String conversationId}) {
    final StreamController<Conversation> controller = StreamController();
    final conversationRef = _conversationRef(conversationId: conversationId);
    RefreshTypingListener? typingListener;
    Conversation? _conversation; // ignore: no_leading_underscores_for_local_identifiers

    final subscription = StreamD(conversationRef.snapshots()).listenD((snapshot) async {
      final snapshotData = snapshot.data();
      if (snapshotData == null) {
        controller.close();
        return;
      }
      _conversation = ConversationModel.fromData(snapshotData, _conversation?.typingUids ?? []);

      typingListener ??= typingDs.addListener(
          conversationId: conversationId,
          listener: (typingUids) {
            print("refreshTypingListener: ${typingUids}");
            _conversation = ConversationModel.fromData(snapshotData, typingUids);
            if(_conversation != null) {
              controller.add(_conversation!);
            } else {
              print("conversationStream: ignoring event because is null #1");
            }
          }
      );

      _conversation = ConversationModel.fromData(snapshotData, _conversation?.typingUids ?? []);
      if(_conversation != null) {
        controller.add(_conversation!);
      } else {
        print("conversationStream: ignoring event because is null #3");
      }
    });

    controller.onCancel = () {
      if (typingListener != null) {
        typingDs.removeListener(listener: typingListener!);
      }
      subscription.cancel();
    };
    subscription.addOnDone(controller.close);

    return controller.stream;
  }

  void addMessage({required SendingMessageEntity message}) {
    assert(authService.loggedUid != null, "current user is not logged in");

    final messageRef = firestore.collection("conversations")
        .doc(message.conversationId)
        .collection("messages")
        .doc();

    final loggedUid = getIt.get<AuthService>().loggedUid;

    messageRef.set(
        MessageFirestoreModel(
          messageId: messageRef.id,
          conversationId: message.conversationId,
          text: message.text,
          senderUid: authService.loggedUid!,
          sentAt: FieldValue.serverTimestamp(),
          receivedAt: {},
          readAt: {},
          participants: message.participants,
          pendingRead: message.participants.where((uid) => uid != loggedUid).toList(),
          pendingReceivement: message.participants.where((uid) => uid != loggedUid).toList(),
        ).toMap()
    );

    print('>>> message sent! at ${DateTime.now().millisecondsSinceEpoch}');
  }

  Stream<int> pendingReadMessagesAmount({required String conversationId}) {
    assert(authService.loggedUid != null, "current user is not logged in");

    return firestore
        .collection("conversations")
        .doc(conversationId)
        .collection("messages")
        .where(MessageFirestoreModel.kPendingRead, arrayContains: authService.loggedUid)
        .snapshots()
        .map((event) => event.size);
  }

  Future<void> updateImTyping({required String conversationId}) async {
    return typingDs.updateImTyping(conversationId);
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/services/auth_service.dart';

const int kTypingDurationMs = 1000;

typedef RefreshTypingListener = void Function(List<String> typingUids);

class TypingDS {
  final FirebaseFirestore firestore;
  final AuthService authService;
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> _subscriptionByConversationId = {};
  final Map<String, List<void Function(List<String> typingUids)>> _listenersByConversationId = {};
  bool _active = false;
  
  /// - Key: conversationId
  /// - Value: Map of:
  /// --- Key: uid
  /// --- Value: Timestamp the user typed at
  final Map<String,Map<String,Timestamp>> _cancelTyping = {};

  final Map<String, List<String>> _typingUidsByConversationId = {};
  final List<void Function()> _onCloseListeners = [];

  TypingDS({
    required this.firestore,
    required this.authService,
  });

  List<String> typingUids (String conversationId) => _typingUidsByConversationId[conversationId] ?? [];

  _triggerListeners({String? conversationId}) {
    if (_active) {
      for (final cId in (conversationId != null ? [conversationId] : _listenersByConversationId.keys)) {
        for (final listener in (_listenersByConversationId[cId] ?? [])) {
          listener(_typingUidsByConversationId[cId]);
        }
      }
    } else {
      print("not calling listeners, because is active is false");
    }
  }

  RefreshTypingListener addListener({required String conversationId, required RefreshTypingListener listener}) {
    _active = true;
    _listenersByConversationId[conversationId] ??= [];
    _listenersByConversationId[conversationId]!.add(listener);
    if (_subscriptionByConversationId[conversationId] != null) {
      _triggerListeners(conversationId: conversationId);
      return listener;
    }
    _subscriptionByConversationId[conversationId] = _ref(conversationId).snapshots().listen((event) {
      final List<String> typingUids = [];

      final typedAtByUid = _convertDocsToTypedAtObject(event);
      print("typedAtByUid");
      print(typedAtByUid);
      for (final String uid in List<String>.from(typedAtByUid.entries.map((e) => e.key))) {
        final DateTime typedAt = typedAtByUid[uid]!.toDate();
        typedAtByUid.remove(uid); // in case the device's clock is not exact
        final cancelTypingByUid = _cancelTyping[conversationId] ??= {};
        if (cancelTypingByUid[uid] != null && cancelTypingByUid[uid]!.millisecondsSinceEpoch > typedAt.millisecondsSinceEpoch) {
          continue;
        }
        cancelTypingByUid.remove(uid);
        const incorrectDevicesClock = 8 * 1000; // in case the devices clock is not exact
        if (DateTime.now().millisecondsSinceEpoch
            - typedAt.millisecondsSinceEpoch <= (kTypingDurationMs + incorrectDevicesClock) ) {
          typingUids.add(uid);
        }
      }
      _typingUidsByConversationId[conversationId] = typingUids;

      _triggerListeners(conversationId: conversationId);
    });
    return listener;
  }
  
  void removeListener({required void Function(List<String> typingUids) listener}) {
    for (final conversationId in _listenersByConversationId.keys) {
      final removed = (_listenersByConversationId[conversationId] ?? []).remove(listener);
      if (removed && _listenersByConversationId[conversationId]!.isEmpty) {
        _subscriptionByConversationId[conversationId]!.cancel();
        _subscriptionByConversationId.remove(conversationId);
        _listenersByConversationId.remove(conversationId);
        _cancelTyping[conversationId]?.clear();
        _typingUidsByConversationId[conversationId]?.clear();
        break;
      }
    }
  }
  
  void cancelTypingForUid({required String conversationId, required String uid}) {
    if (_active) {
      _cancelTyping[conversationId] ??= {};
      _cancelTyping[conversationId]![uid] = Timestamp.now();
      _typingUidsByConversationId[conversationId] = (_typingUidsByConversationId[conversationId] ?? [])
          .where((value) => value != uid).toList();
      _triggerListeners(conversationId: conversationId);
    }
  }

  void close() {
    _active = false;
    for (final subscription in _subscriptionByConversationId.values) {
      subscription.cancel();
    }
    _subscriptionByConversationId.clear();
    _typingUidsByConversationId.clear();
    _listenersByConversationId.clear();
    for (final listener in _onCloseListeners) {
      listener();
    }
    _onCloseListeners.clear();
    _cancelTyping.clear();
  }

  CollectionReference<Map<String,dynamic>> _ref (String conversationId){
    return firestore.collection("conversations").doc(conversationId).collection("typing");
  }

  int? _lastTimeITyped;
  Future<void> updateImTyping(String conversationId) async {
    assert(authService.loggedUid != null, "current user is not logged in");

    final docRef = _ref(conversationId).doc(authService.loggedUid!);
    await docRef.set({ 
      "typedAt": FieldValue.serverTimestamp(),
      "uid": authService.loggedUid!,
    });

    final typedAt = _lastTimeITyped = DateTime.now().millisecondsSinceEpoch;
    Future.delayed(const Duration(milliseconds: kTypingDurationMs), () {
      if (_lastTimeITyped == typedAt) {
        docRef.delete();
      }
    });
  }

  void addOnCloseListener(void Function() listener) {
    if (_active) {
      _onCloseListeners.add(listener);
    } else {
      listener();
    }
  }

  Map<String, Timestamp> _convertDocsToTypedAtObject(QuerySnapshot<Map<String, dynamic>> event) {
    final Map<String, Timestamp> res = {};
    for (final document in event.docs.where((element) => element.id != authService.loggedUid)){
      res[document.id] = document.data()["typedAt"];
    }
    return res;
  }

}
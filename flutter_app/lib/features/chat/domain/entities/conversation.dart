
class Conversation {
  late final String conversationId;

  /// ID's of the members of the conversation
  final List<String> participants;

  /// User IDS of the users who are typing at the same time
  List<String> typingUids;

  bool get isGroup => group != null;

  final ConversationGroup? group;

  Conversation({
    required this.conversationId,
    required this.participants,
    required this.typingUids,
    this.group,
  });

}

class ConversationGroup {
  String title;
  final List<String> adminUids;
  final String createdBy;
  Map<String,DateTime> joinedAt;

  ConversationGroup({required this.title, required this.joinedAt, required this.adminUids, required this.createdBy});
}


class SendingMessageEntity {
  final String conversationId;
  final String text;
  final List<String> participants;

  SendingMessageEntity({
    required this.conversationId,
    required this.text,
    required this.participants,
  }){
    assert(participants.isNotEmpty);
  }


}
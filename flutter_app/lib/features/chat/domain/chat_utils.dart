


String getDirectConversationId (List<String> uids) {
  final aux = uids..sort((a,b) => a.compareTo(b));
  return "direct_${aux.first.substring(0, 14)}${aux.last.substring(0, 14)}";
}

bool isDirectConversation(String? conversationId) {
  return conversationId?.startsWith("direct_") == true;
}
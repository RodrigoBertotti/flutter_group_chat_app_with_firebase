


import '../../data/data_sources/call_ds.dart';
import '../entities/call_credentials.dart';

class CallService {
  final CallDS callDS;

  CallService({required this.callDS});

  Future<CallCredentials> getCallCredentials({required String conversationId}) async {
    return callDS.getCallCredentials(conversationId: conversationId);
  }
}
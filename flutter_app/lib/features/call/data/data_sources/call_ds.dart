
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_group_chat_app_with_firebase/features/call/domain/entities/call_credentials.dart';

class CallDS {
  final FirebaseFunctions firebaseFunctions;
  CallDS ({required this.firebaseFunctions});

  Future<CallCredentials> getCallCredentials({required String conversationId}) async {
    try {
      final res = await FirebaseFunctions
          .instance
          .httpsCallable("getCallCredentials")
          .call({
            "conversationId": conversationId,
          });

      if (res.data != null && res.data["rtcToken"] != null) {
        return CallCredentials(data: CallCredentialsData(
          agoraUid: res.data["agoraUid"],
          rtcToken: res.data["rtcToken"],
        ));
      }
      print ("getCallCredentials: An error occurred");
      return CallCredentials();
    } catch (e){
      print ("getCallCredentials: An error occurred: ${e.toString()}");
      return CallCredentials();
    }
  }

}




class CallCredentials {
  final CallCredentialsData? data;

  bool get success => data != null;

  CallCredentials({this.data});
}

class CallCredentialsData {
  final int agoraUid;
  final String rtcToken;

  CallCredentialsData({required this.agoraUid, required this.rtcToken});
}
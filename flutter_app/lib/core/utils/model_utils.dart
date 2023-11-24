import 'package:cloud_firestore/cloud_firestore.dart';

Map<String,DateTime>? fromMapOfTimestamp (Map<String,dynamic>? map) {
  if (map == null) {
    return null;
  }
  final Map<String,DateTime> res = {};
  for (final entry in Map.from(map).entries) {
    if (entry.value != null) {
      res[entry.key] = (entry.value as Timestamp).toDate();
    } else {
      // if key exists, but value is null, it's a case where you created
      // receivedAt with FieldValue.serverTimestamp();
      // "receivedAt":{
      //   "OGdLCtfMJ3cveXu3qhOvxTPtU0C2": null
      // }
      res[entry.key] = DateTime.now();
    }
  }
  return res;
}
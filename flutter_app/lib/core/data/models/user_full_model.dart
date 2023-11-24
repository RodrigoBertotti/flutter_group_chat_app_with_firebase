import 'package:flutter_group_chat_app_with_firebase/core/data/models/user_public_model.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/user_full.dart';


class UserFullModel extends UserFull {
  /// Field names:
  static const String kUid = "uid";
  static const String kFcmToken = "fcmToken";

  UserFullModel({required String uid, required String firstName, required String lastName, required String? fcmToken})
      : super(uid: uid, firstName: firstName, lastName: lastName, fcmToken: fcmToken,);

  static UserFullModel? fromMap({required Map<String,dynamic>? userFull}) {
    if (userFull == null) {
      return null;
    }
    return UserFullModel(
      uid: userFull[kUid],
      fcmToken: userFull[kFcmToken],
      firstName: userFull[UserPublicModel.kFirstName],
      lastName: userFull[UserPublicModel.kLastName],
    );
  }

  Map<String, dynamic> toMap() => {
    kUid: uid,
    kFcmToken: fcmToken,
    UserPublicModel.kFirstName: firstName,
    UserPublicModel.kLastName: lastName,
  };

}
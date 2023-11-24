import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/user_public.dart';

class UserFull extends UserPublic {
  final String? fcmToken;

  UserFull ({required String uid, required this.fcmToken, required String firstName, required String lastName})
      : super(uid: uid, firstName: firstName, lastName: lastName);
}
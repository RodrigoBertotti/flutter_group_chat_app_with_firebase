import '../../domain/entities/user_public.dart';


class UserPublicModel extends UserPublic {
  /// Field names:
  static const String kUid = "uid";
  static const String kFirstName = "firstName";
  static const String kLastName = "lastName";


  UserPublicModel({required String uid, required String firstName, required String lastName})
      : super(uid: uid, firstName: firstName, lastName: lastName,);

  static UserPublicModel fromMap(map) {
    return UserPublicModel(
      uid: map[kUid],
      firstName: map[kFirstName],
      lastName: map[kLastName],
    );
  }

  static List<UserPublicModel> fromList(List list) {
    return list.map((data) => UserPublicModel.fromMap(data)).toList();
  }

  Map<String, dynamic> toMap() => {
    kUid: uid,
    kFirstName: firstName,
    kLastName: lastName
  };

}
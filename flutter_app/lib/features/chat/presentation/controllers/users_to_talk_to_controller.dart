import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/user_public.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/users_service.dart';
import 'package:flutter_group_chat_app_with_firebase/injection_container.dart';




class UsersToTalkToController {

  Stream<List<UserPublic>> stream() {
    return getIt.get<UsersService>().streamAllUsersExceptLogged();
  }

}
import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/failures/failure.dart';


class EmailAlreadyExistsFailure extends Failure {

  EmailAlreadyExistsFailure() : super ("Email is already in use, please, try to login into your account");

}
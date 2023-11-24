import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/failures/failure.dart';


class InvalidCredentialsFailure extends Failure {

  InvalidCredentialsFailure() : super("Ops! Incorrect email and/or password");

}
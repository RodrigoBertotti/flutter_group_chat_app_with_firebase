

import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/failures/failure.dart';

class InvalidEmailFailure extends Failure {

  InvalidEmailFailure() : super("Oops! This email is not registered yet");

}
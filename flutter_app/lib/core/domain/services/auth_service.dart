import 'package:dartz/dartz.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/services/notifications_service.dart';
import '../../data/data_sources/auth_ds.dart';
import '../entities/failures/failure.dart';
import '../../data/data_sources/users_ds.dart';


class AuthService {
  final AuthDS authDS;
  final UsersDS usersDS;
  final NotificationsService notificationsController;

  AuthService({required this.authDS, required this.usersDS, required this.notificationsController});

  bool get isAuthenticated {
    return authDS.isAuthenticated;
  }

  void addOnSignInListener(void Function() listener) => authDS.addOnSignInListener(listener);

  void addOnSignOutListener(void Function() listener)  => authDS.addOnSignOutListener(listener);

  Future<void> signOut() async {
    await notificationsController.removeTokenFromLoggedUser();
    return authDS.signOut();
  }

  Future<Either<Failure, void>> signInWithEmailAndPassword({required String email, required String password}) async {
    try {
      await authDS.signInWithEmailAndPassword(email: email, password: password);
      return right(null);
    } catch (e) {
      if (e is Failure) {
        return left(e);
      }
      print(e);
      return left(Failure('Ops! An unknown error occurred when trying to sign with with email and password'));
    }
  }

  String? get loggedUid => authDS.loggedUid;

  void removeOnSignOutListener(void Function() listener) {
    authDS.removeOnSignOutListener(listener);
  }

}

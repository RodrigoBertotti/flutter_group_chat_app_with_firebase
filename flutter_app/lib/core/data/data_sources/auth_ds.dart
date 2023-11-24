import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_group_chat_app_with_firebase/features/login_and_registration/domain/entities/failures/invalid_email_failure.dart';
import 'package:flutter_group_chat_app_with_firebase/features/login_and_registration/domain/entities/failures/invalid_password_failure.dart';
import '../../../features/login_and_registration/domain/entities/failures/invalid_credentials_failure.dart';

class AuthDS {
  final FirebaseAuth firebaseAuth;
  final List<void Function()> _onSignOutListeners = [];

  AuthDS({required this.firebaseAuth});
  
  String? get loggedUid => firebaseAuth.currentUser?.uid;

  bool get isAuthenticated {
    return firebaseAuth.currentUser != null;
  }

  void addOnSignInListener(void Function() listener) {
    firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        listener();
      }
    });
  }

  void addOnSignOutListener(void Function() listener) {
    _onSignOutListeners.add(listener);
  }

  void removeOnSignOutListener(void Function() listener) {
    _onSignOutListeners.remove(listener);
  }

  Future<void> signOut() async {
    for (final listener in List.from(_onSignOutListeners)) {
      listener();
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return firebaseAuth.signOut();
  }

  /// throws [InvalidEmailFailure] or [InvalidPasswordFailure]
  Future<void> signInWithEmailAndPassword ({required String email, required String password}) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'INVALID_LOGIN_CREDENTIALS':
          case 'auth/invalid-credential':
          case 'user-not-found':
          case 'invalid-email':
          case 'user-disabled':
            throw InvalidEmailFailure();
          case 'wrong-password':
            throw InvalidPasswordFailure();
          default:
            print("FirebaseAuthException: ${e.code}: ${e.message}");
            throw InvalidCredentialsFailure();
        }
      }
      rethrow;
    }
  }

}

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_group_chat_app_with_firebase/features/login_and_registration/domain/entities/failures/email_already_exists_failure.dart';
import '../entities/user_public.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/failures/failure.dart';
import '../../data/data_sources/users_ds.dart';

class UsersService {
  final UsersDS usersRemoteDataSource;

  UsersService({required this.usersRemoteDataSource});

  /// Creates a new user
  ///
  /// left can only be an instance of:
  /// - [EmailAlreadyExistsFailure]
  /// - [Failure]
  Future<Either<Failure, void>> createUser({required String firstName, required String lastName, required String email, required String password}) async {
    try {
      await usersRemoteDataSource.createUser(firstName: firstName, lastName: lastName, email: email, password: password,);
      return right(null);
    } catch (e) {
      if(e is Failure){
        return left(e);
      }
      print(e.toString());
      return left(Failure("An error occurred when trying to create the user"));
    }
  }
  

  Stream<List<UserPublic>> streamAllUsersExceptLogged() {
    return usersRemoteDataSource.streamAllUsersExceptLogged();
  }

  /// Reads all users the current user can talk to
  Future<List<UserPublic>> getAllUsersExceptLogged() {
    return usersRemoteDataSource.getAllUsersExceptLogged();
  }


  Future<UserPublic?> getUser({required String uid}) {
    return usersRemoteDataSource.getPublicUser(uid: uid);
  }

  Stream<UserPublic> streamPublicUser({required String uid}) {
    return usersRemoteDataSource.streamPublicUser(uid: uid);
  }

}
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:super_manager/core/session/session.manager.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/custom.exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/util/typedef.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/authentication.repository.dart';
import '../data_source/authentication.local.data.source.dart';
import '../data_source/authentictaion.remote.data.source.dart';
import '../models/user.model.dart';

class AuthenticationRepositoryImplementation
    implements AuthenticationRepository {
  AuthenticationRepositoryImplementation(
    this._remoteDataSource,
    this._localDataSource,
  );

  final AuthenticationRemoteDataSource _remoteDataSource;
  final AuthenticationLocalDataSource _localDataSource;
  final _uuid = const Uuid();

  @override
  ResultVoid createUser(
      {required String name,
      required String email,
      required String password,
      required UserRole role}) async {
    try {
      final now = DateTime.now();
      final currentUser = SessionManager.getUserSession()!;

      final user = UserModel(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
        createdBy: currentUser.id,
        administratorId: currentUser.administratorId,
        name: name,
        avatar: 'empty',
        email: email,
        password: password,
        role: role,
        activated: true,
      );
      await _localDataSource.stageCreatedUser(user);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<User> loginWithEmail(
      {required String email, required String password}) async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        final localUser = await _localDataSource.getUserByEmail(email);
        return localUser != null
            ? Right(localUser)
            : const Left(ServerFailure(
                message: 'No local user found', statusCode: 404));
      }

      final remoteUser = await _remoteDataSource.loginWithEmail(email, password);
      await _localDataSource.cacheCurrentUser(remoteUser);
      await _localDataSource.cacheUser(remoteUser);

      return Right(remoteUser);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<User> loginWithGoogle() async {
    try {
      final remoteUser = await _remoteDataSource.loginWithGoogle();
      await _localDataSource.cacheCurrentUser(remoteUser);
      await _localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultVoid logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearCurrentUser();
      await _localDataSource.clearAll();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultVoid resetAccountPassword(String email) {
    throw UnimplementedError();
  }

  @override
  ResultVoid renewEmailAccount(String email) {
    throw UnimplementedError();
  }

  @override
  ResultFuture<List<User>> getUsers(String creatorId) async {
    try {
      final localUsers = await _localDataSource.getUsersForCreator(creatorId);
      return Right(localUsers);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultVoid updateUser(User user) async {
    try {
      await _localDataSource.stageUpdatedUser(UserModel.fromUser(user));
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultVoid deleteUser(String id) async {
    try {
      await _localDataSource.stageDeletedUser(id);
      return const Right(null);
    } catch (e) {
      return Left(LocalFailure(message: e.toString(), statusCode: 500));
    }
  }
  
  @override
  ResultFuture<User> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }
  
  @override
  ResultVoid manageUserStatus(String userUid, bool value) {
    // TODO: implement manageUserStatus
    throw UnimplementedError();
  }
}

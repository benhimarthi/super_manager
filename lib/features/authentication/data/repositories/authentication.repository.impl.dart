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
  final _uui = Uuid();
  @override
  ResultVoid createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final currentUser = SessionManager.getUserSession();
    final user = UserModel(
      id: _uui.v4(),
      createdAt: DateTime.now().toIso8601String(),
      createdBy: currentUser != null ? currentUser.id : "",
      name: name,
      avatar: "empty",
      email: email,
      password: password,
      role: role,
      activated: true,
    );
    try {
      await _remoteDataSource.createUser(user);
      await _localDataSource.cacheUser(user); // Sync to local storage
      return const Right(null);
    } on NetworkException catch (e) {
      await _localDataSource.markUserAsPending(
        user.id,
      ); // Mark user for later sync
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  /*@override
  ResultFuture<User> login({required String email}) async {
    try {
      final remoteUser = await _remoteDataSource.getUserByEmail(email);
      await _localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on NetworkException catch (_) {
      // Try fetching from local storage if network fails
      final localUser = await _localDataSource.getCachedUser(email);
      return localUser != null
          ? Right(localUser)
          : const Left(
              NetworkFailure(message: "No local data found", statusCode: 500));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }*/

  @override
  ResultFuture<User> getCurrentUser() async {
    try {
      final localUser = await _localDataSource.getCurrentUser();
      return localUser != null
          ? Right(localUser)
          : const Left(
              NetworkFailure(message: "No cached user found", statusCode: 500),
            );
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultVoid updateUser(User user) async {
    try {
      await _remoteDataSource.updateUser(
        UserModel.fromMap(((UserModel.fromUser(user)).toMap())),
      );
      await _localDataSource.updateCachedUser(
        UserModel.fromMap(UserModel.fromUser(user).toMap()),
      );
      return const Right(null);
    } on NetworkException catch (_) {
      await _localDataSource.markUserAsUpdated(UserModel.fromUser(user));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultVoid deleteUser(String userId) async {
    try {
      await _remoteDataSource.deleteUser(userId);
      await _localDataSource.removeCachedUser(userId);
      return const Right(null);
    } on NetworkException catch (_) {
      await _localDataSource.markUserAsDeleted(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<User>> getUsers(String userUid) async {
    try {
      final users = await _localDataSource.getCachedUsers(userUid);
      return Right(users);
    } on NetworkException catch (_) {
      final cachedUsers = await _localDataSource.getCachedUsers(userUid);
      return cachedUsers.isNotEmpty
          ? Right(cachedUsers)
          : const Left(
              NetworkFailure(message: "No local data found", statusCode: 500),
            );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        final localUser = await _localDataSource.getCachedUser(email);
        return localUser != null
            ? Right(localUser)
            : const Left(
                NetworkFailure(message: "No local data found", statusCode: 500),
              );
      }
      final remoteUser = await _remoteDataSource.loginWithEmail(
        email,
        password,
      );
      await _localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on NetworkException catch (_) {
      final localUser = await _localDataSource.getCachedUser(email);
      return localUser != null
          ? Right(localUser)
          : const Left(
              NetworkFailure(message: "No local data found", statusCode: 500),
            );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<User> loginWithGoogle() async {
    try {
      final remoteUser = await _remoteDataSource.loginWithGoogle();
      await _localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on NetworkException catch (_) {
      return const Left(
        NetworkFailure(
          message: "Network error during Google login",
          statusCode: 500,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultVoid logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultVoid manageUserStatus(String userUid, bool value) async {
    try {
      final remoteUser = await _remoteDataSource.loginWithGoogle();
      await _localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on NetworkException catch (_) {
      return const Left(
        NetworkFailure(
          message: "Network error during Google login",
          statusCode: 500,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultVoid resetAccountPassword(String email) {
    // TODO: implement resetAccountPassword
    throw UnimplementedError();
  }
}

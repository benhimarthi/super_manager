import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
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
  const AuthenticationRepositoryImplementation(
    this._remoteDataSource,
    this._localDataSource,
  );

  final AuthenticationRemoteDataSource _remoteDataSource;
  final AuthenticationLocalDataSource _localDataSource;

  @override
  ResultVoid createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now().toIso8601String(),
      name: name,
      avatar: "empty",
      email: email,
      password: password,
      role: role,
    );
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      await _localDataSource.cacheUser(user);
      await _localDataSource
          .markUserAsPending(user.id); // Mark user for later sync
      return const Right(null);
    }

    try {
      await _remoteDataSource.createUser(user);
      await _localDataSource.cacheUser(user); // Sync to local storage

      return const Right(null);
    } on NetworkException catch (e) {
      await _localDataSource
          .markUserAsPending(user.id); // Mark user for later sync
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
              NetworkFailure(message: "No cached user found", statusCode: 500));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultVoid updateUser(User user) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await _localDataSource.updateCachedUser(UserModel.fromUser(user));
      await _localDataSource
          .markUserAsUpdated(UserModel.fromUser(user)); // Mark for later sync
      return const Right(null);
    }

    try {
      await _remoteDataSource
          .updateUser(UserModel.fromMap(((UserModel.fromUser(user)).toMap())));
      await _localDataSource
          .cacheUser(UserModel.fromMap(UserModel.fromUser(user).toMap()));
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
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      await _localDataSource
          .markUserAsDeleted(userId); // Flag for deletion when online
      return const Right(null);
    }

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
  ResultFuture<List<User>> getUsers() async {
    try {
      final users = await _remoteDataSource.getUsers();
      for (var t in users) {
        await _localDataSource.cacheUser(t);
      }
      return Right(users);
    } on NetworkException catch (_) {
      final cachedUsers = await _localDataSource.getCachedUsers();
      return cachedUsers.isNotEmpty
          ? Right(cachedUsers)
          : const Left(
              NetworkFailure(message: "No local data found", statusCode: 500));
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
            : const Left(NetworkFailure(
                message: "No local data found", statusCode: 500));
      }

      final remoteUser =
          await _remoteDataSource.loginWithEmail(email, password);
      await _localDataSource.cacheUser(remoteUser);
      return Right(remoteUser);
    } on NetworkException catch (_) {
      final localUser = await _localDataSource.getCachedUser(email);
      return localUser != null
          ? Right(localUser)
          : const Left(
              NetworkFailure(message: "No local data found", statusCode: 500));
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
      return const Left(NetworkFailure(
          message: "Network error during Google login", statusCode: 500));
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
}

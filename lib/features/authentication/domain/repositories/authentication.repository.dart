import '../../../../core/util/typedef.dart';
import '../entities/user.dart';

abstract class AuthenticationRepository {
  const AuthenticationRepository();
  ResultVoid createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });
  ResultFuture<User> loginWithEmail({
    required String email,
    required String password,
  });
  ResultFuture<User> loginWithGoogle();
  ResultVoid logout();
  ResultFuture<User> getCurrentUser();
  ResultVoid updateUser(User user);
  ResultVoid deleteUser(String userId);
  ResultFuture<List<User>> getUsers();
}

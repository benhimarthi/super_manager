import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/user.dart';
import '../repositories/authentication.repository.dart';

class LoginUser extends UsecaseWithParams<User, LoginUserParams> {
  const LoginUser(this._repository);

  final AuthenticationRepository _repository;

  @override
  ResultFuture<User> call(LoginUserParams params) async =>
      _repository.loginWithEmail(
        email: params.email,
        password: params.password,
      );
}

class LoginUserParams {
  final String email;
  final String password;
  const LoginUserParams({
    required this.email,
    required this.password,
  });
}

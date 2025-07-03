import '../../../../core/util/typedef.dart';
import '../entities/user.dart';
import '../repositories/authentication.repository.dart';

class LoginWithGoogle {
  const LoginWithGoogle(this._repository);

  final AuthenticationRepository _repository;

  ResultFuture<User> call() {
    return _repository.loginWithGoogle();
  }
}

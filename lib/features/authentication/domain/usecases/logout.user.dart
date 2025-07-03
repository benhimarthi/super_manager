import '../repositories/authentication.repository.dart';

class LogoutUser {
  const LogoutUser(this._repository);

  final AuthenticationRepository _repository;

  Future<void> call() async {
    await _repository.logout();
  }
}

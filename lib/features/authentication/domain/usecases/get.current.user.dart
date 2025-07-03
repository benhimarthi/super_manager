import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/user.dart';
import '../repositories/authentication.repository.dart';

class GetCurrentUser extends UseCaseWithoutParams<User> {
  const GetCurrentUser(this._repository);

  final AuthenticationRepository _repository;

  @override
  ResultFuture<User> call() async => _repository.getCurrentUser();
}

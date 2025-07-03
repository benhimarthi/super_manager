import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/user.dart';
import '../repositories/authentication.repository.dart';

class UpdateUser extends UsecaseWithParams<void, User> {
  const UpdateUser(this._repository);

  final AuthenticationRepository _repository;

  @override
  ResultFuture<void> call(User params) async => _repository.updateUser(params);
}
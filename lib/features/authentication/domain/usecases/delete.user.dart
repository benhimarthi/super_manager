import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../repositories/authentication.repository.dart';

class DeleteUser extends UsecaseWithParams<void, String> {
  const DeleteUser(this._repository);

  final AuthenticationRepository _repository;

  @override
  ResultFuture<void> call(String params) async => _repository.deleteUser(params);
}
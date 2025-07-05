import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/user.dart';
import '../repositories/authentication.repository.dart';

class GetUsers extends UsecaseWithParams<List<User>, String> {
  const GetUsers(this._repository);

  final AuthenticationRepository _repository;

  @override
  ResultFuture<List<User>> call(String param) async =>
      _repository.getUsers(param);
}

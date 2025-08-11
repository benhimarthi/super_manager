import 'package:super_manager/core/usecase/usecase.dart';
import 'package:super_manager/core/util/typedef.dart';
import 'package:super_manager/features/authentication/domain/repositories/authentication.repository.dart';

class ResetAccountPassword extends UsecaseWithParams<void, String> {
  final AuthenticationRepository _repository;
  ResetAccountPassword(this._repository);

  @override
  ResultFuture<void> call(String params) {
    return _repository.resetAccountPassword(params);
  }
}

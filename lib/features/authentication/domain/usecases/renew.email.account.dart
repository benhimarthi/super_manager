import 'package:super_manager/core/usecase/usecase.dart';
import 'package:super_manager/core/util/typedef.dart';
import 'package:super_manager/features/authentication/domain/repositories/authentication.repository.dart';

class RenewEmailAccount extends UsecaseWithParams<void, String> {
  final AuthenticationRepository _repository;

  RenewEmailAccount(this._repository);

  @override
  ResultFuture<void> call(String params) {
    return _repository.renewEmailAccount(params);
  }
}

import 'package:super_manager/core/usecase/usecase.dart';
import 'package:super_manager/core/util/typedef.dart';
import 'package:super_manager/features/authentication/domain/repositories/authentication.repository.dart';

class ManageUserStatus extends UsecaseWithParams<void, ManageUserStatusParams> {
  final AuthenticationRepository _repository;

  ManageUserStatus(this._repository);

  @override
  ResultFuture<void> call(ManageUserStatusParams params) {
    return _repository.manageUserStatus(params.userUID, params.status);
  }
}

class ManageUserStatusParams {
  final String userUID;
  final bool status;
  ManageUserStatusParams({required this.userUID, required this.status});
}

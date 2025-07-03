import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../repositories/app.image.repository.dart';

class DeleteAppImage extends UsecaseWithParams<void, String> {
  final AppImageRepository repository;

  const DeleteAppImage(this.repository);

  @override
  ResultFuture<void> call(String params) {
    return repository.deleteImage(params);
  }
}

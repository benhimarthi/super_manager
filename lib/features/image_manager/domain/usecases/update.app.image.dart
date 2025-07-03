import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/app.image.dart';
import '../repositories/app.image.repository.dart';

class UpdateAppImage extends UsecaseWithParams<void, AppImage> {
  final AppImageRepository repository;

  const UpdateAppImage(this.repository);

  @override
  ResultFuture<void> call(AppImage params) {
    return repository.updateImage(params);
  }
}

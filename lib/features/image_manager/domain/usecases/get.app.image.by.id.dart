import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/app.image.dart';
import '../repositories/app.image.repository.dart';

class GetAppImageById extends UsecaseWithParams<AppImage, String> {
  final AppImageRepository repository;

  const GetAppImageById(this.repository);

  @override
  ResultFuture<AppImage> call(String params) {
    return repository.getImageById(params);
  }
}

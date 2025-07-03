import '../../../../core/usecase/usecase.dart';
import '../../../../core/util/typedef.dart';
import '../entities/app.image.dart';
import '../repositories/app.image.repository.dart';

class GetImagesForEntity extends UsecaseWithParams<List<AppImage>, String> {
  final AppImageRepository repository;

  const GetImagesForEntity(this.repository);

  @override
  ResultFuture<List<AppImage>> call(String params) {
    return repository.getImagesForEntity(entityId: params);
  }
}

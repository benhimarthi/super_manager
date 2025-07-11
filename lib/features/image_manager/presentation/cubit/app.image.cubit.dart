import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:super_manager/core/image_storage_service/image.storage.service.dart';
import 'package:super_manager/features/image_manager/domain/usecases/get.app.image.by.id.dart';
import '../../../synchronisation/cubit/app_image_synch_manager_cubit/app.image.sync.trigger.cubit.dart';
import '../../domain/entities/app.image.dart';
import '../../domain/usecases/create.app.image.dart';
import '../../domain/usecases/delete.app.image.dart';
import '../../domain/usecases/get.iamges.for.entity.dart';
import '../../domain/usecases/update.app.image.dart';
import 'app.image.state.dart';

class AppImageManagerCubit extends Cubit<AppImageState> {
  final CreateAppImage _create;
  final GetAppImageById _getById;
  final GetImagesForEntity _getAll;
  final UpdateAppImage _update;
  final DeleteAppImage _delete;
  final ImageStorageService _imageStorageService;

  final AppImageSyncTriggerCubit _syncCubit;
  final Connectivity _connectivity;

  AppImageManagerCubit({
    required CreateAppImage create,
    required GetAppImageById getById,
    required GetImagesForEntity getAll,
    required UpdateAppImage update,
    required DeleteAppImage delete,
    required AppImageSyncTriggerCubit syncCubit,
    required Connectivity connectivity,
    required ImageStorageService imageStorageService,
  }) : _create = create,
       _getById = getById,
       _getAll = getAll,
       _update = update,
       _delete = delete,
       _syncCubit = syncCubit,
       _connectivity = connectivity,
       _imageStorageService = imageStorageService,
       super(AppImageManagerLoading());

  Future<void> loadImages(String entityId) async {
    emit(AppImageManagerLoading());
    final result = await _getAll(entityId);
    result.fold(
      (failure) => emit(AppImageManagerError(failure.message)),
      (images) => emit(AppImageManagerLoaded(images)),
    );
  }

  Future<void> createImage(AppImage image) async {
    final result = await _create(image);
    if (result.isLeft()) {
      emit(AppImageManagerError(result.fold((l) => l.message, (_) => '')));
    } else {
      await loadImages(image.entityId);
      await _tryAutoSync();
    }
  }

  Future<void> updateImage(AppImage image) async {
    final result = await _update(image);
    if (result.isLeft()) {
      emit(AppImageManagerError(result.fold((l) => l.message, (_) => '')));
    } else {
      await loadImages(image.entityId);
      await _tryAutoSync();
    }
  }

  Future<void> deleteImage(String id, String entityId) async {
    final result = await _delete(id);
    if (result.isLeft()) {
      emit(AppImageManagerError(result.fold((l) => l.message, (_) => '')));
    } else {
      await loadImages(entityId);
      await _tryAutoSync();
    }
  }

  Future<void> openImageFromGalery(String dirName) async {
    emit(AppImageManagerLoading());
    final result = await _imageStorageService.pick(dirName);
    result.fold(
      (l) => emit(AppImageManagerError(l.message)),
      (r) => emit(OpenImageFromGalerySuccessfully(r)),
    );
  }

  Future<void> getAppImageById(String uid) async {
    final result = await _getById(uid);
    result.fold(
      (l) => emit(AppImageManagerError(l.message)),
      (r) => emit(GetAppImageByIdSuccessfully(r)),
    );
  }

  Future<void> getImagesFromDirectory(String dirName) async {
    final result = await _imageStorageService.getImagesFromDir(dirName);
    result.fold(
      (l) => emit(AppImageManagerError(l.message)),
      (r) => emit(LoadedAllImagesFromDirectorySuccessfully(r)),
    );
  }

  Future<void> _tryAutoSync() async {
    final conn = await _connectivity.checkConnectivity();
    if (conn != ConnectivityResult.none) {
      await _syncCubit.triggerManualSync();
    }
  }
}

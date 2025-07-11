import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';
import '../../../core/util/typedef.dart';
import '../../product_category/data/data_sources/product.category.local.data.source.dart';
import '../../product_category/data/data_sources/product.category.remote.data.source.dart';

class ProductCategorySyncManager {
  final ProductCategoryLocalDataSource _local;
  final ProductCategoryRemoteDataSource _remote;

  ProductCategorySyncManager(this._local, this._remote);

  ResultVoid syncPendingChanges() async {
    try {
      // 🆕 1. Sync Created
      final created = await _local.getPendingCreations();
      for (final model in created) {
        await _remote.createCategory(model);
      }
      await _local.clearSyncedCreations();

      // 🔁 2. Sync Updates
      final updated = await _local.getPendingUpdates();
      for (final model in updated) {
        await _remote.updateCategory(model);
      }
      await _local.clearSyncedUpdates();

      // 🗑️ 3. Sync Deletions
      final deletedIds = await _local.getPendingDeletions();
      for (final id in deletedIds) {
        await _remote.deleteCategory(id);
        await _local.removeSyncedDeletion(id);
      }

      return const Right(null);
    } catch (e) {
      return const Left(
          ServerFailure(message: 'Failed to sync changes', statusCode: 500));
    }
  }
}

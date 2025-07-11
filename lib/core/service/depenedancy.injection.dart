import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:super_manager/features/image_manager/domain/usecases/get.app.image.by.id.dart';
import 'package:super_manager/features/product/domain/usecases/get.product.by.id.dart';
import 'package:super_manager/features/product_pricing/domain/usecases/get.product.pricing.by.id.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../features/authentication/data/data_source/authentication.local.data.source.dart';
import '../../features/authentication/data/data_source/authentictaion.remote.data.source.dart';
import '../../features/authentication/data/data_source/sync.manager.dart';
import '../../features/authentication/data/repositories/authentication.repository.impl.dart';
import '../../features/authentication/domain/repositories/authentication.repository.dart';
import '../../features/authentication/domain/usecases/create.user.dart';
import '../../features/authentication/domain/usecases/delete.user.dart';
import '../../features/authentication/domain/usecases/get.current.user.dart';
import '../../features/authentication/domain/usecases/get.users.dart';
import '../../features/authentication/domain/usecases/login.user.dart';
import '../../features/authentication/domain/usecases/login.with.google.dart';
import '../../features/authentication/domain/usecases/logout.user.dart';
import '../../features/authentication/domain/usecases/update.user.dart';
import '../../features/authentication/presentation/cubit/authentication.cubit.dart';
import '../../features/product/data/data_sources/product.local.data.source.dart';
import '../../features/product/data/data_sources/product.remote.data.source.dart';
import '../../features/product/data/repositories/product.repository.impl.dart';
import '../../features/product/domain/repositories/product.repository.dart';
import '../../features/product/domain/usecases/create.product.dart';
import '../../features/product/domain/usecases/delete.product.dart';
import '../../features/product/domain/usecases/get.all.product.dart';
import '../../features/product/domain/usecases/update.product.dart';
import '../../features/product/presentation/cubit/product.cubit.dart';
import '../../features/product_category/data/data_sources/product.category.local.data.source.dart';
import '../../features/product_category/data/data_sources/product.category.remote.data.source.dart';
import '../../features/product_category/data/repositories/product.category.repository.impl.dart';
import '../../features/product_category/domain/repositories/product.category.repository.dart';
import '../../features/product_category/domain/usecases/create.product.category.dart';
import '../../features/product_category/domain/usecases/delete.product.category.dart';
import '../../features/product_category/domain/usecases/get.all.product.categories.dart';
import '../../features/product_category/domain/usecases/get.product.category.by.id.dart';
import '../../features/product_category/domain/usecases/update.product.category.dart';
import '../../features/image_manager/data/data_source/app.image.local.data.source.dart';
import '../../features/image_manager/data/data_source/app.image.remote.data.source.dart';
import '../../features/image_manager/data/repositories/app.image.repository.impl.dart';
import '../../features/image_manager/domain/repositories/app.image.repository.dart';
import '../../features/image_manager/domain/usecases/create.app.image.dart';
import '../../features/image_manager/domain/usecases/delete.app.image.dart';
import '../../features/image_manager/domain/usecases/get.iamges.for.entity.dart';
import '../../features/image_manager/domain/usecases/update.app.image.dart';
import '../../features/image_manager/presentation/cubit/app.image.cubit.dart';
import '../../features/product_category/presentation/cubit/local.category.manager.cubit.dart';
import '../../features/product_pricing/data/data_source/product.pricing.local.data.source.dart';
import '../../features/product_pricing/data/data_source/product.pricing.remote.data.source.dart';
import '../../features/product_pricing/data/repositories/product.pricing.repository.impl.dart';
import '../../features/product_pricing/domain/repositories/product.pricing.repository.dart';
import '../../features/product_pricing/domain/usecases/create.product.pricing.dart';
import '../../features/product_pricing/domain/usecases/delete.product.pricing.dart';
import '../../features/product_pricing/domain/usecases/get.all.product.pricing.dart';
import '../../features/product_pricing/domain/usecases/update.product.pricing.dart';
import '../../features/product_pricing/presentation/cubit/product.pricing.cubit.dart';
import '../../features/synchronisation/cubit/app_image_synch_manager_cubit/app.image.sync.trigger.cubit.dart';
import '../../features/synchronisation/cubit/authentication_synch_manager_cubit/authentication.sync.trigger.cubit.dart';
import '../../features/synchronisation/cubit/product_category_sync_manager_cubit/product.category.sync.trigger.cubit.dart';
import '../../features/synchronisation/cubit/product_pricing_sync_manager_cubit/product.pricing.sync.trigger.cubit.dart';
import '../../features/synchronisation/cubit/product_sync_manager_cubit/product.sync.trigger.cubit.dart';
import '../../features/synchronisation/synchronisation_manager/app.image.sync.manager.dart';
import '../../features/synchronisation/synchronisation_manager/product.category.sync.manager.dart';
import '../../features/synchronisation/synchronisation_manager/product.pricing.sync.manager.dart';
import '../../features/synchronisation/synchronisation_manager/product.sync.manager.dart';
import '../image_storage_service/image.storage.service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('authenticationBox'); // Open the authentication box

  // Register Firebase Services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<Box>(() => Hive.box('authenticationBox'));

  // Register Data Sources
  getIt.registerLazySingleton<AuthenticationRemoteDataSource>(
    () => AuthenticationRemoteDataSrcImpl(
      getIt<FirebaseAuth>(),
      getIt<FirebaseFirestore>(),
    ),
  );
  getIt.registerLazySingleton<AuthenticationLocalDataSource>(
    () => AuthenticationLocalDataSrcImpl(getIt<Box>()),
  );

  // Register Repositories
  getIt.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImplementation(
      getIt<AuthenticationRemoteDataSource>(),
      getIt<AuthenticationLocalDataSource>(),
    ),
  );

  //Rgistration of the synchronisator
  getIt.registerLazySingleton<SyncManager>(
    () => SyncManager(
      getIt<AuthenticationRemoteDataSource>(),
      getIt<AuthenticationLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<AuthenticationSyncTriggerCubit>(
    () => AuthenticationSyncTriggerCubit(getIt<SyncManager>()),
  );

  // Register Use Cases
  getIt.registerLazySingleton<CreateUser>(
    () => CreateUser(getIt<AuthenticationRepository>()),
  );
  getIt.registerLazySingleton<LoginUser>(
    () => LoginUser(getIt<AuthenticationRepository>()),
  );
  getIt.registerLazySingleton<LoginWithGoogle>(
    () => LoginWithGoogle(getIt<AuthenticationRepository>()),
  );
  getIt.registerLazySingleton<GetUsers>(
    () => GetUsers(getIt<AuthenticationRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(getIt<AuthenticationRepository>()),
  );
  getIt.registerLazySingleton<UpdateUser>(
    () => UpdateUser(getIt<AuthenticationRepository>()),
  );
  getIt.registerLazySingleton<DeleteUser>(
    () => DeleteUser(getIt<AuthenticationRepository>()),
  );
  getIt.registerLazySingleton<LogoutUser>(
    () => LogoutUser(getIt<AuthenticationRepository>()),
  );

  // Register Cubit for Authentication
  getIt.registerFactory(
    () => AuthenticationCubit(
      createUser: getIt<CreateUser>(),
      getUsers: getIt<GetUsers>(),
      loginUser: getIt<LoginUser>(),
      loginWithGoogle: getIt<LoginWithGoogle>(),
      updateUser: getIt<UpdateUser>(),
      deleteUser: getIt<DeleteUser>(),
      logoutUser: getIt<LogoutUser>(),
      getCurrentUser: getIt<GetCurrentUser>(),
    ),
  );
  // Open Hive boxes
  final mainBox = await Hive.openBox('product_categories');
  final createdBox = await Hive.openBox('product_categories_created');
  final updatedBox = await Hive.openBox('product_categories_updated');
  final deletedBox = await Hive.openBox('product_categories_deleted');
  // Local Data Source
  getIt
    ..registerFactory(
      () => LocalCategoryManagerCubit(
        getAll: getIt(),
        create: getIt(),
        update: getIt(),
        delete: getIt(),
        connectivity: getIt(),
        syncCubit: getIt(),
      ),
    )
    ..registerLazySingleton(() => CreateProductCategory(getIt()))
    ..registerLazySingleton(() => GetAllProductCategories(getIt()))
    ..registerLazySingleton(() => GetProductCategoryById(getIt()))
    ..registerLazySingleton(() => UpdateProductCategory(getIt()))
    ..registerLazySingleton(() => DeleteProductCategory(getIt()))
    ..registerLazySingleton<ProductCategoryLocalDataSource>(
      () => ProductCategoryLocalDataSourceImpl(
        mainBox: mainBox,
        createdBox: createdBox,
        updatedBox: updatedBox,
        deletedBox: deletedBox,
      ),
    )
    ..registerLazySingleton<ProductCategoryRemoteDataSource>(
      () => ProductCategoryRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ProductCategoryRepository>(
      () => ProductCategoryRepositoryImpl(getIt()),
    );

  getIt
    ..registerLazySingleton(
      () => ProductCategorySyncManager(
        getIt<ProductCategoryLocalDataSource>(),
        getIt<ProductCategoryRemoteDataSource>(),
      ),
    )
    ..registerFactory(() => ProductCategorySyncTriggerCubit(getIt()));

  /*getIt.registerLazySingleton(
    () => RefreshCategoriesFromRemote(
      getIt(),
      getIt(),
    ),
  );*/

  final ppm = await Hive.openBox('product_pricing_main');
  final ppc = await Hive.openBox('product_pricing_created');
  final ppu = await Hive.openBox('product_pricing_updated');
  final ppd = await Hive.openBox<String>('product_pricing_deleted');

  getIt
    ..registerFactory(
      () => ProductPricingCubit(
        getAll: getIt(),
        getById: getIt(),
        create: getIt(),
        update: getIt(),
        delete: getIt(),
        syncCubit: getIt(),
        connectivity: getIt(),
      ),
    )
    ..registerLazySingleton(() => GetAllProductPricing(getIt()))
    ..registerLazySingleton(() => GetProductPricingById(getIt()))
    ..registerLazySingleton(() => CreateProductPricing(getIt()))
    ..registerLazySingleton(() => UpdateProductPricing(getIt()))
    ..registerLazySingleton(() => DeleteProductPricing(getIt()))
    ..registerLazySingleton(() => ProductPricingSyncTriggerCubit(getIt()))
    ..registerLazySingleton<ProductPricingRepository>(
      () => ProductPricingRepositoryImpl(local: getIt()),
    )
    ..registerLazySingleton<ProductPricingLocalDataSource>(
      () => ProductPricingLocalDataSourceImpl(
        mainBox: ppm,
        createdBox: ppc,
        updatedBox: ppu,
        deletedBox: ppd,
      ),
    )
    ..registerLazySingleton<ProductPricingRemoteDataSource>(
      () => ProductPricingRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ProductPricingSyncManager>(
      () => ProductPricingSyncManagerImpl(getIt(), getIt()),
    );

  final productBox = await Hive.openBox('products');
  final createdProductBox = await Hive.openBox('products_created');
  final updatedProductBox = await Hive.openBox('products_updated');
  final deletedProductBox = await Hive.openBox('products_deleted');

  getIt
    ..registerFactory(
      () => ProductCubit(
        create: getIt(),
        getAll: getIt(),
        getById: getIt(),
        update: getIt(),
        delete: getIt(),
        connectivity: getIt(),
        syncCubit: getIt(),
      ),
    )
    ..registerLazySingleton(() => CreateProduct(getIt()))
    ..registerLazySingleton(() => GetAllProducts(getIt()))
    ..registerLazySingleton(() => GetProductById(getIt()))
    ..registerLazySingleton(() => UpdateProduct(getIt()))
    ..registerLazySingleton(() => DeleteProduct(getIt()))
    ..registerLazySingleton(() => ProductSyncTriggerCubit(getIt()))
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(local: getIt()),
    )
    ..registerLazySingleton<ProductLocalDataSource>(
      () => ProductLocalDataSourceImpl(
        mainBox: productBox,
        createdBox: createdProductBox,
        updatedBox: updatedProductBox,
        deletedBox: deletedProductBox,
      ),
    )
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ProductSyncManager>(
      () => ProductSyncManagerImpl(getIt(), getIt()),
    );
  /*
  final inventoryBox = await Hive.openBox('inventories');
  final createdinventoryBox = await Hive.openBox('inventories_created');
  final updatedinventoryBox = await Hive.openBox('inventories_updated');
  final deletedinventoryBox = await Hive.openBox<String>('inventories_deleted');
  getIt
    ..registerFactory(
      () => InventoryCubit(
        getAll: getIt(),
        create: getIt(),
        update: getIt(),
        delete: getIt(),
        syncCubit: getIt(),
        connectivity: getIt(),
      ),
    )
    ..registerLazySingleton(() => GetAllInventory(getIt()))
    ..registerLazySingleton(() => CreateInventory(getIt()))
    ..registerLazySingleton(() => UpdateInventory(getIt()))
    ..registerLazySingleton(() => DeleteInventory(getIt()))
    ..registerLazySingleton(() => InventorySyncTriggerCubit(getIt()))
    ..registerLazySingleton<InventoryRepository>(
      () => InventoryRepositoryImpl(
        local: getIt(),
      ),
    )
    ..registerLazySingleton<InventoryLocalDataSource>(
      () => InventoryLocalDataSourceImpl(
        mainBox: inventoryBox,
        createdBox: createdinventoryBox,
        updatedBox: updatedinventoryBox,
        deletedBox: deletedinventoryBox,
      ),
    )
    ..registerLazySingleton<InventoryRemoteDataSource>(
        () => InventoryRemoteDataSourceImpl(getIt()))
    ..registerLazySingleton<InventorySyncManager>(
      () => InventorySyncManagerImpl(
        getIt(),
        getIt(),
      ),
    );

  final inventoryMetadataBox = await Hive.openBox('inventoryMetadata');
  final createdInventoryMetadataBox =
      await Hive.openBox('inventoryMetadata_created');
  final updatedInventoryMetadataBox =
      await Hive.openBox('inventoryMetadata_updated');
  final deletedInventoryMetadataBox =
      await Hive.openBox<String>('inventoryMetadata_deleted');
  getIt
    ..registerFactory(
      () => InventoryMetadataCubit(
        getAll: getIt(),
        create: getIt(),
        update: getIt(),
        delete: getIt(),
        syncCubit: getIt(),
        connectivity: getIt(),
      ),
    )
    ..registerLazySingleton(() => GetAllInventoryMetadata(getIt()))
    ..registerLazySingleton(() => CreateInventoryMetadata(getIt()))
    ..registerLazySingleton(() => UpdateInventoryMetadata(getIt()))
    ..registerLazySingleton(() => DeleteInventoryMetadata(getIt()))
    ..registerLazySingleton(() => InventoryMetadataSyncTriggerCubit(getIt()))
    ..registerLazySingleton<InventoryMetadataRepository>(
        () => InventoryMetadataRepositoryImpl(local: getIt()))
    ..registerLazySingleton<InventoryMetadataLocalDataSource>(
      () => InventoryMetadataLocalDataSourceImpl(
        mainBox: inventoryMetadataBox,
        createdBox: createdInventoryMetadataBox,
        updatedBox: updatedInventoryMetadataBox,
        deletedBox: deletedInventoryMetadataBox,
      ),
    )
    ..registerLazySingleton<InventoryMetadataRemoteDataSource>(
        () => InventoryMetadataRemoteDataSourceImpl(getIt()))
    ..registerLazySingleton<InventoryMetadataSyncManager>(
      () => InventoryMetadataSyncManagerImpl(
        getIt(),
        getIt(),
      ),
    );*/

  final appImageBox = await Hive.openBox('appImages');
  final createdappImageBox = await Hive.openBox('app_image_created');
  final updatedappImageBox = await Hive.openBox('app_image_updated');
  final deletedappImageBox = await Hive.openBox<String>('app_image_deleted');
  //Image manager
  getIt.registerLazySingleton<ImageStorageService>(() => ImageStorageService());
  getIt
    ..registerFactory(
      () => AppImageManagerCubit(
        create: getIt(),
        getById: getIt(),
        getAll: getIt(),
        update: getIt(),
        delete: getIt(),
        syncCubit: getIt(),
        connectivity: getIt(),
        imageStorageService: getIt(),
      ),
    )
    ..registerLazySingleton(() => CreateAppImage(getIt()))
    ..registerLazySingleton(() => GetAppImageById(getIt()))
    ..registerLazySingleton(() => GetImagesForEntity(getIt()))
    ..registerLazySingleton(() => UpdateAppImage(getIt()))
    ..registerLazySingleton(() => DeleteAppImage(getIt()))
    ..registerLazySingleton(() => AppImageSyncTriggerCubit(getIt()))
    ..registerLazySingleton<AppImageSyncManager>(
      () => AppImageSyncManagerImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<AppImageRepository>(
      () => AppImageRepositoryImpl(local: getIt()),
    )
    ..registerLazySingleton<AppImageLocalDataSource>(
      () => AppImageLocalDataSourceImpl(
        mainBox: appImageBox,
        createdBox: createdappImageBox,
        updatedBox: updatedappImageBox,
        deletedBox: deletedappImageBox,
      ),
    )
    ..registerLazySingleton<AppImageRemoteDataSource>(
      () => AppImageRemoteDataSourceImpl(firestore: getIt()),
    );
  getIt.registerFactory(() => WidgetManipulatorCubit());
}

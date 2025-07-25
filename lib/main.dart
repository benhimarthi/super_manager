import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:super_manager/features/sale/presentation/cubit/sale.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/authentication_synch_manager_cubit/authentication.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/sale_synch_manager_cubit/sale.sync.trigger.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import 'package:super_manager/firebase_options.dart';
import 'core/app_theme/app.theme.dart';
import 'core/service/depenedancy.injection.dart';
import 'features/Inventory/presentation/cubit/inventory.cubit.dart';
import 'features/authentication/presentation/cubit/authentication.cubit.dart';
import 'features/authentication/presentation/pages/login_screen/login.screen.dart';
import 'features/authentication/presentation/pages/registration_screen/registration.screen.dart';
import 'features/authentication/presentation/pages/splash_screen/splash.screen.dart';
import 'features/authentication/presentation/pages/user_management_screen/main.screen.dart';
import 'features/image_manager/presentation/cubit/app.image.cubit.dart';
import 'features/product/presentation/cubit/product.cubit.dart';
import 'features/product_category/presentation/cubit/local.category.manager.cubit.dart';
import 'features/product_pricing/presentation/cubit/product.pricing.cubit.dart';
import 'features/synchronisation/cubit/app_image_synch_manager_cubit/app.image.sync.trigger.cubit.dart';
import 'features/synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.cubit.dart';
import 'features/synchronisation/cubit/inventory_meta_data_sync_trigger_cubit/inventory.meta.data.sync.trigger.cubit.dart';
import 'features/synchronisation/cubit/inventory_sync_trigger_cubit/inventory.sync.trigger.cubit.dart';
import 'features/synchronisation/cubit/product_category_sync_manager_cubit/product.category.sync.trigger.cubit.dart';
import 'features/synchronisation/cubit/product_pricing_sync_manager_cubit/product.pricing.sync.trigger.cubit.dart';
import 'features/synchronisation/cubit/product_sync_manager_cubit/product.sync.trigger.cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationCubit>(
          create: (context) => getIt<AuthenticationCubit>(),
        ),
        BlocProvider<AuthenticationSyncTriggerCubit>(
          create: (context) => getIt<AuthenticationSyncTriggerCubit>(),
        ),
        BlocProvider<LocalCategoryManagerCubit>(
          create: (context) => getIt<LocalCategoryManagerCubit>(),
        ),
        BlocProvider<ProductCategorySyncTriggerCubit>(
          create: (context) => getIt<ProductCategorySyncTriggerCubit>(),
        ),
        BlocProvider<ProductPricingCubit>(
          create: (context) => getIt<ProductPricingCubit>(),
        ),
        BlocProvider<ProductPricingSyncTriggerCubit>(
          create: (context) => getIt<ProductPricingSyncTriggerCubit>(),
        ),
        BlocProvider<ProductCubit>(create: (context) => getIt<ProductCubit>()),
        BlocProvider<ProductSyncTriggerCubit>(
          create: (context) => getIt<ProductSyncTriggerCubit>(),
        ),
        BlocProvider<InventoryCubit>(
          create: (context) => getIt<InventoryCubit>(),
        ),
        BlocProvider<InventorySyncTriggerCubit>(
          create: (context) => getIt<InventorySyncTriggerCubit>(),
        ),
        BlocProvider<InventoryMetadataCubit>(
          create: (context) => getIt<InventoryMetadataCubit>(),
        ),
        BlocProvider<InventoryMetadataSyncTriggerCubit>(
          create: (context) => getIt<InventoryMetadataSyncTriggerCubit>(),
        ),
        BlocProvider<AppImageSyncTriggerCubit>(
          create: (context) => getIt<AppImageSyncTriggerCubit>(),
        ),
        BlocProvider<AppImageManagerCubit>(
          create: (context) => getIt<AppImageManagerCubit>(),
        ),
        BlocProvider<WidgetManipulatorCubit>(
          create: (context) => getIt<WidgetManipulatorCubit>(),
        ),
        BlocProvider<SaleCubit>(create: (context) => getIt<SaleCubit>()),
        BlocProvider<SaleSyncTriggerCubit>(
          create: (context) => getIt<SaleSyncTriggerCubit>(),
        ),
      ],
      child: Builder(
        builder: ((context) {
          return MaterialApp.router(
            title: 'your Manager',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: GoRouter(
              initialLocation: "/users", // Corrected splash/splash
              routes: [
                GoRoute(
                  path: '/splash',
                  builder: (context, state) => const SplashScreen(),
                ),
                GoRoute(
                  path: '/login',
                  builder: (context, state) => const LoginScreen(),
                ),
                GoRoute(
                  path: '/register',
                  builder: (context, state) => const RegistrationScreen(),
                ),
                GoRoute(
                  path: '/users',
                  builder: (context, state) => const MainScreen(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

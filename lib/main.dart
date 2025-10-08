import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:super_manager/core/notification_service/flutter.local.notifications.plugin.dart';
import 'package:super_manager/features/action_history/presentation/cubit/action.history.cubit.dart';
import 'package:super_manager/features/notification_manager/data/models/notification.model.dart';
import 'package:super_manager/features/notification_manager/presentation/cubit/notification.cubit.dart';
import 'package:super_manager/features/sale/presentation/cubit/sale.cubit.dart';
import 'package:super_manager/features/sale_item/presentation/cubit/sale.item.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/action_history_synch_manager_cubit/action.history.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/authentication_synch_manager_cubit/authentication.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/notification_synch_manager_cubit/notification.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/sale_item_sync_manager_cubit/sale.item.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/sale_sync_manager_cubit/sale.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/synchronisation_manager/app.image.sync.manager.dart';
import 'package:super_manager/features/synchronisation/synchronisation_manager/inventory.meta.data.sync.manager.dart';
import 'package:super_manager/features/synchronisation/synchronisation_manager/inventory.sync.manager.dart';
import 'package:super_manager/features/synchronisation/synchronisation_manager/product.category.sync.manager.dart';
import 'package:super_manager/features/synchronisation/synchronisation_manager/product.pricing.sync.manager.dart';
import 'package:super_manager/features/synchronisation/synchronisation_manager/product.sync.manager.dart';
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
import 'features/inventory_meta_data/presentation/inventory_meta_data_cubit/inventory.meta.data.cubit.dart';
import 'features/synchronisation/cubit/inventory_meta_data_sync_trigger_cubit/inventory.meta.data.sync.trigger.cubit.dart';
import 'features/synchronisation/cubit/inventory_sync_trigger_cubit/inventory.sync.trigger.cubit.dart';
import 'features/synchronisation/cubit/product_category_sync_manager_cubit/product.category.sync.trigger.cubit.dart';
import 'features/synchronisation/cubit/product_pricing_sync_manager_cubit/product.pricing.sync.trigger.cubit.dart';
import 'features/synchronisation/cubit/product_sync_manager_cubit/product.sync.trigger.cubit.dart';

late StreamSubscription<QuerySnapshot> _subscription;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDependencyInjection();
  await initializeNotificationService();

  runApp(const MyApp());
  // Listen to Firestore collection called 'action_history'
  getIt<ProductSyncManager>().initialize();
  getIt<ProductPricingSyncManager>().initialize();
  getIt<ProductCategorySyncManager>().initialize();
  getIt<InventorySyncManager>().startSync();
  getIt<InventoryMetadataSyncManager>().startSync();
  getIt<AppImageSyncManager>().initialize();
  _subscription = FirebaseFirestore.instance
      .collection('notifications')
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            var notif = NotificationModel.fromMap(
              change.doc.data() as Map<String, dynamic>,
            );

            var updatedNotif = notif.copyWith(isDelivered: true);
            getIt<NotificationCubit>().updateNotification(updatedNotif);
            // When a new document is added, trigger a local notification
            if (!notif.isDelivered) {
              showNotification(
                title: change.doc['title'] ?? 'New Notification',
                body: change.doc['body'] ?? 'You have a new notification',
              );
            }
          }
        }
      });
}

Future<void> showNotification({
  required String title,
  required String body,
}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'default_channel', // Use the actual channel ID you created
        '', // Leave the channel name empty here, as it cannot be changed here
        importance: Importance.high,
        priority: Priority.high,
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'Notification Payload',
  );
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
        BlocProvider<SaleItemCubit>(
          create: (context) => getIt<SaleItemCubit>(),
        ),
        BlocProvider<SaleItemSyncTriggerCubit>(
          create: (context) => getIt<SaleItemSyncTriggerCubit>(),
        ),
        BlocProvider<SaleItemSyncTriggerCubit>(
          create: (context) => getIt<SaleItemSyncTriggerCubit>(),
        ),
        BlocProvider<ActionHistoryCubit>(
          create: (context) => getIt<ActionHistoryCubit>(),
        ),
        BlocProvider<ActionHistorySyncTriggerCubit>(
          create: (context) => getIt<ActionHistorySyncTriggerCubit>(),
        ),
        BlocProvider<NotificationCubit>(
          create: (context) => getIt<NotificationCubit>(),
        ),
        BlocProvider<NotificationSyncTriggerCubit>(
          create: (context) => getIt<NotificationSyncTriggerCubit>(),
        ),
      ],
      child: Builder(
        builder: ((context) {
          return MaterialApp.router(
            title: 'your Manager',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: GoRouter(
              initialLocation: "/splash", // Corrected splash/splash/users
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

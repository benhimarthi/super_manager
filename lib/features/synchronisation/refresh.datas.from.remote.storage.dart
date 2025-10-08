import 'package:flutter/material.dart';
import 'package:super_manager/core/service/depenedancy.injection.dart';
import 'package:super_manager/features/synchronisation/cubit/action_history_synch_manager_cubit/action.history.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/app_image_synch_manager_cubit/app.image.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/inventory_meta_data_sync_trigger_cubit/inventory.meta.data.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/inventory_sync_trigger_cubit/inventory.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/notification_synch_manager_cubit/notification.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/product_category_sync_manager_cubit/product.category.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/product_pricing_sync_manager_cubit/product.pricing.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/product_sync_manager_cubit/product.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/sale_item_sync_manager_cubit/sale.item.sync.trigger.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/sale_sync_manager_cubit/sale.sync.trigger.cubit.dart';
import '../../core/util/change.screen.manager.dart';
import '../authentication/presentation/pages/user_management_screen/main.screen.dart';

class RefreshDatasFromRemoteStorage extends StatelessWidget {
  const RefreshDatasFromRemoteStorage({super.key});

  restoreDatasFromRemoteSource() async {
    //await getIt<SyncManager>().refreshFromRemote();
    await getIt<ActionHistorySyncTriggerCubit>().refreshFromRemote();
    await getIt<AppImageSyncTriggerCubit>().refreshFromRemote();
    await getIt<InventorySyncTriggerCubit>().refreshFromRemote();
    await getIt<InventoryMetadataSyncTriggerCubit>().refreshFromRemote();
    await getIt<NotificationSyncTriggerCubit>().refreshFromRemote();
    await getIt<ProductSyncTriggerCubit>().refreshFromRemote();
    await getIt<ProductCategorySyncTriggerCubit>().refreshFromRemote();
    await getIt<ProductPricingSyncTriggerCubit>().refreshFromRemote();
    await getIt<SaleSyncTriggerCubit>().refreshFromRemote();
    await getIt<SaleItemSyncTriggerCubit>().refreshFromRemote();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Restore Data",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(onTap: () {}, child: Icon(Icons.help, size: 18)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('We will preceed to restore the datas from your remote source.'),
          SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              restoreDatasFromRemoteSource();
              nextScreenReplace(context, MainScreen());
            },
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: const Color.fromARGB(82, 127, 7, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Text(
                  "Preceed",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              nextScreenReplace(context, MainScreen());
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: const Color.fromARGB(82, 127, 7, 255),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Center(child: Text("Decline")),
            ),
          ),
        ],
      ),
    );
  }
}

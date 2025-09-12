import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/Inventory/presentation/cubit/inventory.cubit.dart';
import 'package:super_manager/features/inventory_meta_data/domain/entities/inventory.meta.data.dart';
import 'package:super_manager/features/synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.cubit.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/notification_service/notification.params.dart';
import '../../../../core/session/session.manager.dart';
import '../../../notification_manager/domain/entities/notification.dart';
import '../../../notification_manager/presentation/cubit/notification.cubit.dart';

class DeleteInventoryConfirmationView extends StatelessWidget {
  final Inventory deletedInventory;
  final InventoryMetadata? inventoryMetaData;
  const DeleteInventoryConfirmationView({
    super.key,
    required this.deletedInventory,
    required this.inventoryMetaData,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Deletion Confirmation",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Do your really wish to remove, this Inventory ?"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  context.read<InventoryCubit>().deleteInventory(
                    deletedInventory.id,
                  );
                  context.read<InventoryMetadataCubit>().deleteMetadata(
                    inventoryMetaData!.id,
                  );
                  final adminUid =
                      SessionManager.getUserSession()!.administratorId;
                  final date = DateTime.now();
                  var notif = Notifications(
                    id: Uuid().v4(),
                    title: "Inventory deletion",
                    body:
                        "The user ${SessionManager.getUserSession()!.name} deleted An Inventory",
                    type: NotificationCategory.alert.name,
                    priority: NotificationPriority.high.name,
                    status: NotificationStatus.unread.name,
                    recipientId: adminUid ?? "",
                    senderId: SessionManager.getUserSession()!.id,
                    createdAt: date,
                    sentAt: date,
                    expiresAt: DateTime(3000),
                    channel: NotificationChannel.inApp.name,
                    isDelivered: false,
                    deviceToken: "notification",
                    actionUrl: "INVENTORY",
                    actions: ["read"],
                    metadata: {"product_id": deletedInventory.id},
                    retriesCount: 0,
                    readCount: 0,
                    adminId:
                        SessionManager.getUserSession()!.administratorId != null
                        ? SessionManager.getUserSession()!.administratorId!
                        : SessionManager.getUserSession()!.id,
                  );
                  context.read<NotificationCubit>().addNotification(notif);
                  Navigator.pop(context);
                },
                child: Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

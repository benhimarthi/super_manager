import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/notification_service/notification.params.dart';
import '../../../../core/session/session.manager.dart';
import '../../../notification_manager/domain/entities/notification.dart';
import '../../../notification_manager/presentation/cubit/notification.cubit.dart';
import '../cubit/product.cubit.dart';

class DeleteProductConfirmationScreen extends StatelessWidget {
  final Product deletedProduct;
  const DeleteProductConfirmationScreen({
    super.key,
    required this.deletedProduct,
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
          Text("Do your really wish to remove, this Product ?"),
          ListTile(
            //leading: CircleAvatar(),
            title: Text(
              deletedProduct.name,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            //subtitle: Text(deletedProduct.role.name),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  context.read<ProductCubit>().deleteProduct(deletedProduct.id);
                  final adminUid =
                      SessionManager.getUserSession()!.administratorId;
                  final date = DateTime.now();
                  var notif = Notifications(
                    id: Uuid().v4(),
                    title: "Product deletion",
                    body:
                        "The user ${SessionManager.getUserSession()!.name} deleted the product ${deletedProduct.name}",
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
                    actionUrl: "PRODUCTS",
                    actions: ["read"],
                    metadata: {"product_id": deletedProduct.id},
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/apllication_method/inventory.meta.data.methods.dart';
import 'package:super_manager/core/history_actions/action.create.history.dart';
import 'package:super_manager/core/session/session.manager.dart';
import 'package:super_manager/features/Inventory/data/models/inventory.model.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/Inventory/presentation/cubit/inventory.cubit.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.form.data.dart';
import 'package:super_manager/features/action_history/presentation/cubit/action.history.cubit.dart';
import 'package:super_manager/features/inventory_meta_data/data/models/inventory.meta.data.model.dart';
import 'package:super_manager/features/inventory_meta_data/domain/entities/inventory.meta.data.dart';
import 'package:super_manager/features/product/data/models/product.model.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';
import 'package:super_manager/features/product/presentation/cubit/product.cubit.dart';
import 'package:super_manager/features/product_pricing/data/models/product.pricing.model.dart';
import 'package:super_manager/features/product_pricing/domain/entities/product.pricing.dart';
import 'package:super_manager/features/synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.cubit.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/notification_service/notification.params.dart';
import '../../../notification_manager/domain/entities/notification.dart';
import '../../../notification_manager/presentation/cubit/notification.cubit.dart';

class InventoryMetaDataForm extends StatefulWidget {
  final Inventory? inventory;
  final Inventory? oldVersion;
  final InventoryMetadata? inventoryMetadata;
  final bool isBuilding;
  final bool duplicate;
  const InventoryMetaDataForm({
    super.key,
    required this.inventory,
    this.inventoryMetadata,
    required this.isBuilding,
    required this.duplicate,
    this.oldVersion,
  });

  @override
  State<InventoryMetaDataForm> createState() => _InventoryMetaDataFormState();
}

class _InventoryMetaDataFormState extends State<InventoryMetaDataForm> {
  late Product inventoryProduct;
  late ProductPricing productPricing;
  late Inventory inv;
  late InventoryMetaDataMethods cl;
  late double costPerUnity = 0;
  late double totalStockValue = 1500;
  late TextEditingController _totalStockValue;
  late TextEditingController _leadTime;
  late bool isEditing;
  late String metaDataUid;
  final _formKey = GlobalKey<FormState>();

  late String markupPercentage;
  late String averageDailySales;
  late double stockTurnoverRate;
  late double leadTimeInDays;
  late double demandForecast;
  late double seasonalityFactor;
  late double inventorySource;

  @override
  void initState() {
    super.initState();

    markupPercentage = "0";
    if (widget.inventoryMetadata != null) {
      isEditing = true;
    } else {
      isEditing = false;
    }
    _totalStockValue = TextEditingController(
      text: widget.inventoryMetadata != null
          ? widget.inventoryMetadata!.totalStockValue.toString()
          : "0.0",
    );
    _leadTime = TextEditingController(
      text: widget.inventoryMetadata != null
          ? widget.inventoryMetadata!.leadTimeInDays.toString()
          : "0",
    );
    metaDataUid = widget.inventoryMetadata?.id ?? Uuid().v4();
    cl = InventoryMetaDataMethods();
    inv = (widget.inventory ?? InventoryModel.empty());
    inventoryProduct = ProductModel.empty();
    productPricing = ProductPricingModel.empty();
    costPerUnity = cl.costPerUnit(totalStockValue, inv.quantityAvailable);
    if (widget.inventory != null) {
      context.read<ProductCubit>().getProductById(widget.inventory!.productId);
    }
  }

  _save() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.isBuilding) {
        final metadata = InventoryMetadata(
          id: metaDataUid,
          inventoryId: inv.id,
          costPerUnit: costPerUnity,
          totalStockValue: double.parse(_totalStockValue.text),
          markupPercentage: 0,
          averageDailySales: 0,
          stockTurnoverRate: 0,
          leadTimeInDays: int.parse(_leadTime.text),
          demandForecast: 0,
          seasonalityFactor: 0,
          inventorySource: "",
          createdBy: SessionManager.getUserSession()!.id,
          updatedBy: SessionManager.getUserSession()!.id,
        );
        var currentUser = SessionManager.getUserSession()!;
        //final info = NetworkInfo();
        //String? wifiIP = await info.getWifiIP();
        context.read<InventoryCubit>().addInventory(widget.inventory!);
        context.read<InventoryMetadataCubit>().addMetadata(metadata);
        var history = addHistoryItem(
          "inventory",
          widget.inventory!.id,
          widget.inventory!.productId,
          "create",
          currentUser.id,
          currentUser.name,
          "create inventory",
          {
            "inventory": InventoryModel.fromEntity(widget.inventory!).toMap(),
            "inventory_meta_data": InventoryMetadataModel.fromEntity(
              metadata,
            ).toMap(),
          },
          {"ip": "192.72.0.0", "device": "Android", "location": "location"},
          "inventory-management",
          "none",
          "created",
        );
        context.read<ActionHistoryCubit>().addHistory(history);
        final adminUid = SessionManager.getUserSession()!.administratorId;
        final date = DateTime.now();
        var notif = Notifications(
          id: Uuid().v4(),
          title: "Inventory creation",
          body:
              "The user ${SessionManager.getUserSession()!.name} Create the inventory of the product ${inventoryProduct.name}",
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
          metadata: {"inventory_id": inv.id},
          retriesCount: 0,
          readCount: 0,
          adminId: SessionManager.getUserSession()!.administratorId != null
              ? SessionManager.getUserSession()!.administratorId!
              : SessionManager.getUserSession()!.id,
        );
        context.read<NotificationCubit>().addNotification(notif);
      } else {
        var metadata =
            InventoryMetadataModel.fromEntity(
              widget.inventoryMetadata!,
            ).copyWith(
              totalStockValue: double.parse(_totalStockValue.text),
              costPerUnit:
                  double.parse(_totalStockValue.text) / inv.quantityAvailable,
              leadTimeInDays: int.parse(_leadTime.text),
              updatedBy: SessionManager.getUserSession()!.id,
            );
        context.read<InventoryCubit>().updateInventory(widget.inventory!);
        context.read<InventoryMetadataCubit>().updateMetadata(metadata);
        if (widget.duplicate ||
            metadata.totalStockValue !=
                widget.inventoryMetadata!.totalStockValue) {
          var currentUser = SessionManager.getUserSession()!;
          var history = addHistoryItem(
            "inventory",
            widget.inventory!.id,
            widget.inventory!.productId,
            "update",
            currentUser.id,
            currentUser.name,
            "update inventory",
            {
              "inventory": {
                "old_version": InventoryModel.fromEntity(
                  widget.oldVersion!,
                ).toMap(),
                "new_version": InventoryModel.fromEntity(
                  widget.inventory!,
                ).toMap(),
              },
              "inventory_meta_data": {
                "old_version": InventoryMetadataModel.fromEntity(
                  widget.inventoryMetadata!,
                ).toMap(),
                "new_version": InventoryMetadataModel.fromEntity(
                  metadata,
                ).toMap(),
              },
            },
            {"ip": "192.72.0.0", "device": "Android", "location": "location"},
            "inventory-management",
            "none",
            "updated",
          );
          context.read<ActionHistoryCubit>().addHistory(history);
          final adminUid = SessionManager.getUserSession()!.administratorId;
          final date = DateTime.now();
          var notif = Notifications(
            id: Uuid().v4(),
            title: "Inventory update",
            body:
                "The user ${SessionManager.getUserSession()!.name} updated the inventory of the product ${inventoryProduct.name}",
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
            metadata: {"inventory_id": inv.id},
            retriesCount: 0,
            readCount: 0,
            adminId: SessionManager.getUserSession()!.administratorId != null
                ? SessionManager.getUserSession()!.administratorId!
                : SessionManager.getUserSession()!.id,
          );
          context.read<NotificationCubit>().addNotification(notif);
        }
      }
    }
  }

  @override
  void dispose() {
    _totalStockValue.dispose();
    _leadTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Inventory metaData',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) {
                  return InventoryFormData(
                    inventory: widget.inventory,
                    myInventories: [],
                    isBuilding: true,
                  );
                },
              );
            },
            child: Text(
              "Prev",
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _totalStockValue,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: Text("Total stock value"),
                      suffixIcon: Icon(
                        Icons.help,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "This filed can not be null";
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _leadTime,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: Text("Lead Time"),
                      suffixIcon: Icon(
                        Icons.help,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  inventoryMetaDataItem(String title, String value, String unity) {
    return Container(
      width: 135,
      decoration: BoxDecoration(
        color: Color.fromARGB(102, 159, 122, 234),
        borderRadius: BorderRadius.circular(5),
        /*BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),*/
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 3),
                    CircleAvatar(
                      radius: 10,
                      child: Center(child: Icon(Icons.help, size: 18)),
                    ),
                  ],
                ),
              ),
              Container(
                width: 130,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: " $unity",
                          style: TextStyle(
                            color: Colors.lightGreen,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

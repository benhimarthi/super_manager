import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';
import 'package:super_manager/features/notification_manager/domain/entities/notification.dart';
import 'package:super_manager/features/notification_manager/presentation/cubit/notification.cubit.dart';
import 'package:super_manager/features/product/data/models/product.model.dart';
import 'package:super_manager/features/product_pricing/presentation/cubit/product.pricing.state.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.state.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/history_actions/action.create.history.dart';
import '../../../../core/notification_service/notification.params.dart';
import '../../../../core/session/session.manager.dart';
import '../../../action_history/presentation/cubit/action.history.cubit.dart';
import '../../../image_manager/domain/entities/app.image.dart';
import '../../../product_pricing/presentation/cubit/product.pricing.cubit.dart';
import '../../domain/entities/product.dart';
import '../cubit/product.cubit.dart';
import '../widgets/product.pricing.view.dart';

class ProductSecondFormPage extends StatefulWidget {
  final List<AppImage> myProductImages;
  final bool creation;
  const ProductSecondFormPage({
    super.key,
    required this.myProductImages,
    required this.creation,
  });

  @override
  State<ProductSecondFormPage> createState() => _ProductSecondFormPageState();
}

class _ProductSecondFormPageState extends State<ProductSecondFormPage> {
  late TextEditingController _unit;
  late TextEditingController _barcode;
  late Product? product;
  bool _active = true;
  late String princingValue = "";

  @override
  void initState() {
    super.initState();
    var state = context.read<WidgetManipulatorCubit>().state;
    context.read<ProductPricingCubit>().loadPricing();
    if (state is CacheProductSuccessfully) {
      product = state.product;
    } else {
      product = null;
    }
    _unit = TextEditingController(text: product != null ? product!.unit : "");
    _barcode = TextEditingController(
      text: product != null ? product!.barcode : "",
    );
    _active = product != null ? product!.active : _active;
  }

  _submit() {
    for (var t in widget.myProductImages) {
      context.read<AppImageManagerCubit>().createImage(t);
    }
    final finalProduct = ProductModel.fromEntity(product!).copyWith(
      barcode: _barcode.text.trim(),
      unit: _unit.text.trim(),
      active: _active,
      pricingId: princingValue.isNotEmpty
          ? princingValue
          : (product != null ? product!.pricingId : ""),
    );
    final cubit = context.read<ProductCubit>();
    var currentUser = SessionManager.getUserSession()!;
    if (widget.creation) {
      cubit.addProduct(finalProduct);
      var history = addHistoryItem(
        "product",
        finalProduct.id,
        finalProduct.name,
        "create",
        currentUser.id,
        currentUser.name,
        "create product",
        {
          "product": {
            "first_version": ProductModel.fromEntity(finalProduct).toMap(),
          },
        },
        {"ip": "192.72.0.0", "device": "Android", "location": "location"},
        "product-management",
        "none",
        "created",
      );
      context.read<ActionHistoryCubit>().addHistory(history);
      final adminUid = SessionManager.getUserSession()!.administratorId;
      final date = DateTime.now();
      var notif = Notifications(
        id: Uuid().v4(),
        title: "Product creation",
        body:
            "The user ${SessionManager.getUserSession()!.name} created the product ${product!.name}",
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
        metadata: {"product_id": product!.id},
        retriesCount: 0,
        readCount: 0,
        adminId: SessionManager.getUserSession()!.administratorId != null
            ? SessionManager.getUserSession()!.administratorId!
            : SessionManager.getUserSession()!.id,
      );
      context.read<NotificationCubit>().addNotification(notif);
    } else {
      cubit.updateProduct(finalProduct);
      var history = addHistoryItem(
        "product",
        finalProduct.id,
        finalProduct.name,
        "update",
        currentUser.id,
        currentUser.name,
        "update product",
        {
          "product": {
            "old_version": ProductModel.fromEntity(product!).toMap(),
            "new_version": ProductModel.fromEntity(finalProduct).toMap(),
          },
        },
        {"ip": "192.72.0.0", "device": "Android", "location": "location"},
        "product-management",
        "none",
        "updated",
      );
      context.read<ActionHistoryCubit>().addHistory(history);
      final adminUid = SessionManager.getUserSession()!.administratorId;
      final date = DateTime.now();
      var notif = Notifications(
        id: Uuid().v4(),
        title: "Product updated",
        body:
            "The user ${SessionManager.getUserSession()!.name} updated the product ${product!.name}",
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
        metadata: {"product_id": product!.id},
        retriesCount: 0,
        readCount: 0,
        adminId: SessionManager.getUserSession()!.administratorId != null
            ? SessionManager.getUserSession()!.administratorId!
            : SessionManager.getUserSession()!.id,
      );
      context.read<NotificationCubit>().addNotification(notif);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
      listener: (context, state) {
        if (state is CacheProductSuccessfully) {
          var product = state.product;
          _unit = TextEditingController(text: product.unit);
          _barcode = TextEditingController(text: product.barcode);
          _active = product.active;
        }
        if (state is ElementAddedSuccessfully) {
          setState(() {
            princingValue = state.elementId;
          });
        }
        if (state is EmitRandomElementSuccessfully) {
          try {
            final data = state.element as Map<dynamic, dynamic>;
            if (data['id'] == 'select_product_pricing') {
              setState(() {
                princingValue = data['pricing_id']!;
                var prod = ProductModel.fromEntity(
                  product!,
                ).copyWith(pricingId: princingValue);
                context.read<ProductCubit>().updateProduct(prod);
              });
            }
            // ignore: empty_catches
          } catch (e) {}
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              BlocConsumer<ProductPricingCubit, ProductPricingState>(
                listener: (context, state) {
                  if (state is ProductPricingManagerLoaded) {
                    if (state.pricingList.isNotEmpty && product != null) {
                      final prices = state.pricingList
                          .where((x) => x.productId == product!.id)
                          .toList();

                      if (prices.isNotEmpty) {
                        princingValue = prices.first.id;
                      }
                    }
                  }
                },
                builder: (context, state) {
                  return ProductPricingView(
                    productId: product != null ? product!.id : "",
                  );
                },
              ),

              SizedBox(height: 10),
              TextFormField(
                controller: _unit,
                decoration: const InputDecoration(
                  labelText: 'Unit (e.g. kg, box)',
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _barcode,
                decoration: InputDecoration(
                  labelText: 'Barcode',
                  suffixIcon: Icon(
                    Icons.barcode_reader,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Active'),
                value: _active,
                onChanged: (val) => setState(() => _active = val),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _submit, child: const Text('Save')),
            ],
          ),
        );
      },
    );
  }
}

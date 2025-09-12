import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/session/session.manager.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/inventory_meta_data/domain/entities/inventory.meta.data.dart';
import 'package:super_manager/features/sale/data/models/sale.model.dart';
import 'package:super_manager/features/sale_item/data/models/sale.item.model.dart';
import 'package:super_manager/features/sale_item/domain/entities/sale.item.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import 'package:uuid/uuid.dart';

import '../../../product/domain/entities/product.dart';
import '../../../product_pricing/domain/entities/product.pricing.dart';
import '../../../sale/domain/entities/sale.dart';

class RegisterSaleForm extends StatefulWidget {
  final ProductPricing productPricing;
  final Product productSale;
  final Inventory inventory;
  final InventoryMetadata inventoryMetadata;
  const RegisterSaleForm({
    super.key,
    required this.productPricing,
    required this.productSale,
    required this.inventory,
    required this.inventoryMetadata,
  });

  @override
  State<RegisterSaleForm> createState() => _RegisterSaleFormState();
}

class _RegisterSaleFormState extends State<RegisterSaleForm> {
  late String productStatus;
  late int quantity;
  final _uuid = Uuid();
  late String saleUid;
  late String saleItemUid;
  late Sale sale;
  late SaleItem saleItem;
  @override
  void initState() {
    super.initState();
    productStatus = 'Paid';
    saleUid = _uuid.v4();
    saleItemUid = _uuid.v4();
    quantity = 1;
    saleProduct();
  }

  void saleProduct() {
    final session = SessionManager.getUserSession()!;
    final adminId = session.administratorId ?? session.id;

    // Ensure discountPercent is fraction
    double discountPerUnit =
        widget.productPricing.amount *
        (widget.productPricing.discountPercent / 100);
    double discountedUnitPrice = widget.productPricing.amount - discountPerUnit;

    double totalAmount = discountedUnitPrice * quantity;

    sale = Sale(
      id: saleUid,
      customerId: session.id,
      date: DateTime.now(),
      status: productStatus,
      totalAmount: totalAmount,
      totalTax: 0,
      discountAmount: discountPerUnit * quantity,
      paymentMethod: "Card",
      currency: widget.productPricing.currency,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      adminId: adminId,
    );

    saleItem = SaleItem(
      id: saleItemUid,
      saleId: saleUid,
      productId: widget.productSale.id,
      quantity: quantity,
      unitPrice: discountedUnitPrice,
      totalPrice: totalAmount,
      taxAmount: 0,
      discountApplied: discountPerUnit * quantity,
      adminId: adminId,
    );

    context.read<WidgetManipulatorCubit>().emitRandomElement({
      "id": "sale",
      "product_name": widget.productSale.name,
      "sale": sale,
      "sale_item": saleItem,
    });
  }

  updateSaleItem() {
    double discountAmount =
        widget.productPricing.amount *
        (widget.productPricing.discountPercent / 100);
    double totalAmount =
        (widget.productPricing.amount - discountAmount) * quantity;
    var updatedItem = SaleModel.fromEntity(sale).copyWith(
      totalAmount: totalAmount,
      status: productStatus,
      updatedAt: DateTime.now(),
    );
    var updateSaleItem = SaleItemModel.fromEntity(saleItem).copyWith(
      quantity: quantity,
      totalPrice: widget.inventoryMetadata.costPerUnit * quantity,
    );
    context.read<WidgetManipulatorCubit>().emitRandomElement({
      "id": "sale_update",
      "product_name": widget.productSale.name,
      "sale": updatedItem,
      "sale_item": updateSaleItem,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Register Sale",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 35,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (quantity > 1) quantity -= 1;
                        updateSaleItem();
                      });
                    },
                    child: CircleAvatar(
                      radius: 14,
                      child: Center(child: Icon(Icons.remove, size: 16)),
                    ),
                  ),
                  Text(
                    'x${quantity.toString()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (quantity < widget.inventory.quantityAvailable) {
                          quantity += 1;
                        }
                      });
                      updateSaleItem();
                    },
                    child: CircleAvatar(
                      radius: 14,
                      child: Center(child: Icon(Icons.add, size: 16)),
                    ),
                  ),
                ],
              ),
            ),
            DropdownButton<String>(
              underline: SizedBox(),
              value: productStatus,
              items: ['Paid', 'Pending', 'Reserved', 'Missed']
                  .map(
                    (period) => DropdownMenuItem(
                      value: period,
                      child: Text(
                        period,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 70, 43, 122),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  productStatus = value!;
                  updateSaleItem();
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

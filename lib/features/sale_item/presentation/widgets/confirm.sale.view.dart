import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/data/models/inventory.model.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/Inventory/presentation/cubit/inventory.cubit.dart';
import 'package:super_manager/features/sale/presentation/cubit/sale.cubit.dart';
import 'package:super_manager/features/sale_item/presentation/cubit/sale.item.cubit.dart';
import 'package:super_manager/features/sale_item/presentation/widgets/sale.item.list.dart';
import 'package:super_manager/features/sale_item/presentation/widgets/sale.product.item.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';

class ConfirmSaleView extends StatefulWidget {
  final List<Inventory> inventory;
  const ConfirmSaleView({super.key, required this.inventory});

  @override
  State<ConfirmSaleView> createState() => _ConfirmSaleViewState();
}

class _ConfirmSaleViewState extends State<ConfirmSaleView> {
  late Map<String, dynamic> saleItems;
  @override
  void initState() {
    super.initState();
    saleItems = {};
  }

  _saveSales() {
    for (var n in saleItems.values) {
      context.read<SaleCubit>().addSale(n[1]);
      context.read<SaleItemCubit>().addSaleItem(n[2]);
      //Update the inventory productId
      final productId = n[2].productId;
      var inventory = widget.inventory
          .where((x) => x.productId == productId)
          .firstOrNull;
      if (inventory != null) {
        int qtt = n[2].quantity;
        int qttAvailable = inventory.quantityAvailable - qtt;
        int qttSold = 0;
        int reservedQtt = 0;
        switch (n[1].status) {
          case "Paid":
            qttSold = inventory.quantitySold + qtt;
            break;
          case "Pending":
          case "Reserved":
            reservedQtt = inventory.quantityReserved + qtt;
            break;
        }
        var updatedInv = InventoryModel.fromEntity(inventory).copyWith(
          quantityAvailable: qttAvailable,
          quantitySold: qttSold,
          quantityReserved: reservedQtt,
        );
        context.read<InventoryCubit>().updateInventory(updatedInv);
      }
      context.read<WidgetManipulatorCubit>().emitRandomElement({
        "id": "delete_sale",
        "sale_id": n[1].id,
        "product_id": n[2].productId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
        listener: (context, state) {
          if (state is EmitRandomElementSuccessfully) {
            try {
              setState(() {
                var value = (state.element as Map<String, dynamic>);
                if (value['id'] == "sale") {
                  saleItems[value['sale'].id] = [
                    value['product_name'],
                    value['sale'],
                    value['sale_item'],
                  ];
                } else if (value['id'] == "sale_update") {
                  saleItems[value['sale'].id] = [
                    value['product_name'],
                    value['sale'],
                    value['sale_item'],
                  ];
                } else if (value['id'] == "delete_sale") {
                  saleItems.remove(value['sale_id']);
                }
              });
            } catch (e) {}
          }
        },
        builder: (context, state) {
          return Visibility(
            visible: saleItems.isNotEmpty,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: 340,
              //height: 100,
              decoration: BoxDecoration(
                color: Colors.green, //Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(166, 255, 255, 255),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SaleItemList(saleItems: saleItems);
                              },
                            );
                          },
                          child: Text(
                            "See More...",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: saleItems.length > 1
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final data = saleItems.values.toList()[0];
                            final productName = data.first;
                            final totalAmount = data[1].totalAmount;
                            final quantity = data[2].quantity;
                            return saleProductItem(
                              context,
                              productName,
                              totalAmount,
                              quantity,
                              onDelete: () {
                                context
                                    .read<WidgetManipulatorCubit>()
                                    .emitRandomElement({
                                      "id": "delete_sale",
                                      "sale_id": data[1].id,
                                      "product_id": data[2].productId,
                                    });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _saveSales();
                      setState(() {
                        saleItems = {};
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Center(
                        child: Text(
                          "REGISTER SALES",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

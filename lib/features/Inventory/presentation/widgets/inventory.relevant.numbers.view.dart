import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/apllication_method/inventory.kpi.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/action_history/domain/entities/action.history.dart';
import 'package:super_manager/features/inventory_meta_data/domain/entities/inventory.meta.data.dart';
import 'package:super_manager/features/sale/domain/entities/sale.dart';
import 'package:super_manager/features/sale/presentation/cubit/sale.cubit.dart';
import 'package:super_manager/features/sale_item/domain/entities/sale.item.dart';
import 'package:super_manager/features/sale_item/presentation/cubit/sale.item.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

import '../../../sale/presentation/cubit/sale.state.dart';
import '../../../sale_item/presentation/cubit/sale.item.state.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';

class InventoryRelevantNumbersView extends StatefulWidget {
  final Inventory inventory;
  final InventoryMetadata inventoryMetadata;
  final List<Inventory> inventoryVersions;
  final List<ActionHistory> myInventoryHistories;
  const InventoryRelevantNumbersView({
    super.key,
    required this.inventory,
    required this.inventoryVersions,
    required this.myInventoryHistories,
    required this.inventoryMetadata,
  });

  @override
  State<InventoryRelevantNumbersView> createState() =>
      _InventoryRelevantNumbersViewState();
}

class _InventoryRelevantNumbersViewState
    extends State<InventoryRelevantNumbersView> {
  late Set<SaleItem> saleItems;
  late List<Sale> sales;
  late DateTime _startDate;
  late DateTime _endDate;
  late int totalUnit = 0;

  @override
  void initState() {
    super.initState();
    saleItems = {};
    sales = [];
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    totalUnit =
        widget.inventory.quantityAvailable +
        widget.inventory.quantityReserved +
        widget.inventory.quantitySold;
    context.read<SaleCubit>().loadSales();
  }

  Widget _inventoryNbInfos(String title, double value, bool selected) {
    return Container(
      height: 60,
      width: 100,
      padding: EdgeInsets.all(3),
      margin: EdgeInsets.symmetric(horizontal: 3),
      decoration: selected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.amber, width: 2),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: const Color.fromARGB(255, 88, 88, 88),
                width: 2,
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 4),
          SizedBox(
            width: 55,
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  salesQuantityDuringPeriod(List<Sale> sales, Set<SaleItem> saleItems) {
    var periodSale = sales
        .where((x) => x.date.isAfter(_startDate) && x.date.isBefore(_endDate))
        .toList()
        .where((x) => x.status == "Paid")
        .toList();
    var saleItemsPeriod = saleItems
        .where((x) => periodSale.map((y) => y.id).contains(x.saleId))
        .toList();
    final salePeriod = saleItemsPeriod.map((y) => y.quantity).toList();
    int saleQuantityPeriod = salePeriod.isNotEmpty
        ? salePeriod.reduce((a, b) => a + b)
        : 0;
    final salesRevenue = saleItemsPeriod
        .map((x) => x.quantity * x.unitPrice)
        .toList();
    double amount = salesRevenue.isNotEmpty
        ? salesRevenue.reduce((a, b) => a + b)
        : 0;
    return {
      "period_quantity_sold": saleQuantityPeriod,
      "period_quantity_revenue": amount,
    };
  }

  startDateProductAvailableQuantity(List<Sale> sales, Set<SaleItem> saleItems) {
    final prevInventories = widget.myInventoryHistories
        .where((x) => x.timestamp.isBefore(_startDate))
        .toList();
    prevInventories.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final earliestRestock = prevInventories.lastOrNull;
    final salesAfterLastRestock = sales
        .where(
          (x) =>
              x.date.isAfter(earliestRestock!.timestamp) &&
              x.date.isBefore(_startDate),
        )
        .toList();

    final salesItemsALR = saleItems
        .where(
          (x) => salesAfterLastRestock
              .map((x) => x.id)
              .toList()
              .contains(x.saleId),
        )
        .toList();
    int quantitySale = salesItemsALR.isNotEmpty
        ? salesItemsALR.map((x) => x.quantity).toList().reduce((a, b) => a + b)
        : 0;
    final res = earliestRestock!.action == "update"
        ? earliestRestock
                  .changes['inventory']!['new_version']['quantityAvailable'] -
              quantitySale
        : earliestRestock.changes['inventory']!['quantityAvailable'] -
              quantitySale;
    double unitPrice = earliestRestock
        .changes['inventory_meta_data']!['new_version']['costPerUnit'];
    return {
      "start_date_quantity": res,
      "start_date_unit_cost": unitPrice,
      "amount": res * unitPrice,
    };
  }

  endDateProductAvailableQuantity(List<Sale> sales, Set<SaleItem> saleItems) {
    final nextInventories = widget.myInventoryHistories
        .where((x) => x.timestamp.isAfter(_endDate))
        .toList();
    nextInventories.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final closetRestock = nextInventories.firstOrNull;
    DateTime refDate = DateTime.now();
    int quantityLastRestock = widget.inventory.quantityAvailable;
    if (closetRestock != null) {
      refDate = closetRestock.timestamp;
      quantityLastRestock = closetRestock
          .changes['inventory']!['old_version']['quantityAvailable'];
    }
    final salesAfterLastRestock = sales
        .where((x) => x.date.isAfter(_endDate) && x.date.isBefore(refDate))
        .toList();
    final salesItemsALR = saleItems
        .where(
          (x) => salesAfterLastRestock
              .map((x) => x.id)
              .toList()
              .contains(x.saleId),
        )
        .toList();
    int quantitySale = salesItemsALR.isNotEmpty
        ? salesItemsALR.map((x) => x.quantity).toList().reduce((a, b) => a + b)
        : 0;
    final result = quantityLastRestock - quantitySale;
    double unitPrice = closetRestock != null
        ? closetRestock
              .changes['inventory_meta_data']!['new_version']['costPerUnit']
        : widget.inventoryMetadata.costPerUnit;
    return {
      "end_date_quantity": result,
      "end_date_unit_price": unitPrice,
      "amount": result * unitPrice,
    };
  }

  periodSupplyQttValue() {
    final supply = widget.myInventoryHistories.where(
      (x) => x.timestamp.isBefore(_endDate) && x.timestamp.isAfter(_startDate),
    );
    final supplies = supply.where((x) => x.action != "update").toList();
    if (supplies.isNotEmpty) {
      int qtt = 0;
      double price = 0;
      for (var n in supplies) {
        int nV = n.changes['inventory']!['new_version']['quantityAvailable'];
        int oV = n.changes['inventory']!['old_version']['quantityAvailable'];
        int diffV = (nV - oV).abs();
        qtt += diffV;
        final p =
            diffV *
            n.changes['inventory_meta_data']!['new_version']['costPerUnit'];
        price += p;
      }

      return {"supply_quantity": qtt, "supply_cost": price};
    } else {
      return {"supply_quantity": 0, "supply_cost": 0};
    }
  }

  averageInventory() {
    return InventoryKPI.averageInventory(
      startDateProductAvailableQuantity(sales, saleItems)['amount'],
      endDateProductAvailableQuantity(sales, saleItems)['amount'],
    );
  }

  COGS() {
    //Cost of goods
    return startDateProductAvailableQuantity(sales, saleItems)['amount'] +
        periodSupplyQttValue()['supply_cost'] +
        endDateProductAvailableQuantity(sales, saleItems)['amount'];
  }

  inventoryTurnOver() {
    return InventoryKPI.inventoryTurnover(COGS(), averageInventory());
  }

  grossMarginReturnOnInvestment() {
    return InventoryKPI.gmroi(
      salesQuantityDuringPeriod(sales, saleItems)['period_quantity_revenue'],
      COGS(),
      averageInventory(),
    );
  }

  @override
  Widget build(BuildContext context) {
    startDateProductAvailableQuantity(sales, saleItems);
    return SizedBox(
      width: double.infinity,
      height: 100,
      //color: Colors.green,
      child: BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
        listener: (context, state) {
          if (state is EmitRandomElementSuccessfully) {
            try {
              var data = (state.element as Map<String, dynamic>);
              if (data['id'] == "filter_sales_by_date") {
                _startDate = data['start_date'];
                _endDate = data['end_date'];
              }
            } catch (e) {}
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocConsumer<SaleCubit, SaleState>(
                listener: (context, state) {
                  if (state is SaleManagerLoaded) {
                    sales = state.saleList;
                    for (var n in sales) {
                      context.read<SaleItemCubit>().loadSaleItems(n.id);
                    }
                  }
                },
                builder: (context, state) {
                  return Container();
                },
              ),
              BlocConsumer<SaleItemCubit, SaleItemState>(
                listener: (context, state) {
                  if (state is SaleItemManagerLoaded) {
                    if (state.saleItemList.isNotEmpty) {
                      var t = state.saleItemList.firstOrNull;
                      if (t != null) {
                        if (t.productId == widget.inventory.productId) {
                          saleItems.add(state.saleItemList.first);
                        }
                      }
                    }
                  }
                },
                builder: (context, state) {
                  return Container();
                },
              ),
              Text(
                "Stock turn over rate",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.amber),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _inventoryNbInfos(
                      "Average inventory",
                      averageInventory(),
                      false,
                    ),
                    _inventoryNbInfos(
                      "Stock turn over rate",
                      inventoryTurnOver(),
                      false,
                    ),
                    _inventoryNbInfos(
                      "gross Margin Return On Investment",
                      grossMarginReturnOnInvestment(),
                      false,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

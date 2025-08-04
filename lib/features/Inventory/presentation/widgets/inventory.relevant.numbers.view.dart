import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/action_history/domain/entities/action.history.dart';
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
  final List<Inventory> inventoryVersions;
  final List<ActionHistory> myInventoryHistories;
  const InventoryRelevantNumbersView({
    super.key,
    required this.inventory,
    required this.inventoryVersions,
    required this.myInventoryHistories,
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
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  salesQuantityDuringPeriod(List<Sale> sales, Set<SaleItem> saleItems) {
    var periodSale = sales
        .where((x) => x.date.isAfter(_startDate) && x.date.isBefore(_endDate))
        .toList();
    var saleItemsPeriod = saleItems
        .where((x) => periodSale.map((y) => y.id).contains(x.saleId))
        .toList();
    var restockQuantity = widget.inventoryVersions
        .where(
          (x) =>
              x.updatedAt.isAfter(_startDate) && x.updatedAt.isBefore(_endDate),
        )
        .toList();
    int saleQuantityPeriod = saleItemsPeriod
        .map((y) => y.quantity)
        .reduce((a, b) => a + b);
    return saleQuantityPeriod;
  }

  startDateProductAvailableQuantity(List<Sale> sales, Set<SaleItem> saleItems) {
    final prevInventories = widget.myInventoryHistories
        .where((x) => x.timestamp.isBefore(_startDate))
        .toList();
    prevInventories.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    //print(prevInventories.first.changes['inventory']!['new_version']);
    print(prevInventories.map((x) => x.timestamp).toList());
    final earliestRestock = prevInventories.last;
    final salesAfterLastRestock = sales
        .where(
          (x) =>
              x.date.isAfter(earliestRestock.timestamp) &&
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
    print(salesItemsALR);
    int quantitySale = salesItemsALR.isNotEmpty
        ? salesItemsALR.map((x) => x.quantity).toList().reduce((a, b) => a + b)
        : 0;
    int startDateSales =
        earliestRestock
            .changes['inventory']!['new_version']['quantityAvailable'] -
        quantitySale;
    //int evailableQuantityToStartingDate =
    //earliestRestock.quantityAvailable - quantitySale;
    //int salesDuringPeriod =
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
                    _inventoryNbInfos("Average inventory", 0.5, false),
                    _inventoryNbInfos("Stock turn over rate", 0.5, false),
                    _inventoryNbInfos("Stock turn over rate", 0.5, false),
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

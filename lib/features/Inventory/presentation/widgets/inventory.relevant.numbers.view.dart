import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/apllication_method/inventory.kpi.dart';
import 'package:super_manager/core/apllication_method/inventory.kpi.information.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/component.info.dialog.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.item.kpi.chart.view.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/period.informations.datas.dart';
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
  late String currentKpiTitle;
  late double currentKpiValue;

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
    currentKpiTitle = "Average inventory";
    currentKpiValue = averageInventory();
    context.read<SaleCubit>().loadSales();
  }

  Widget _inventoryNbInfos(String title, double value, bool selected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentKpiTitle = title;
          currentKpiValue = value;
        });
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "select_inventory_kpi",
          "kpi": title,
        });
      },
      child: Container(
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
                  color: currentKpiTitle == title
                      ? Colors.green
                      : const Color.fromARGB(255, 88, 88, 88),
                  width: currentKpiTitle == title ? 5 : 2,
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
      ),
    );
  }

  averageInventory() {
    return InventoryKPI.averageInventory(
      PeriodInformationsDatas.startDateProductAvailableQuantity(
        sales,
        saleItems,
        widget.myInventoryHistories,
        _startDate,
      )['amount'],
      PeriodInformationsDatas.endDateProductAvailableQuantity(
        sales,
        saleItems,
        widget.myInventoryHistories,
        widget.inventory,
        widget.inventoryMetadata,
        _endDate,
      )['amount'],
    );
  }

  COGS() {
    //Cost of goods
    return PeriodInformationsDatas.startDateProductAvailableQuantity(
          sales,
          saleItems,
          widget.myInventoryHistories,
          _startDate,
        )['amount'] +
        PeriodInformationsDatas.periodSupplyQttValue(
          widget.myInventoryHistories,
          _startDate,
          _endDate,
        )['supply_cost'] +
        PeriodInformationsDatas.endDateProductAvailableQuantity(
          sales,
          saleItems,
          widget.myInventoryHistories,
          widget.inventory,
          widget.inventoryMetadata,
          _endDate,
        )['amount'];
  }

  inventoryTurnOver() {
    return InventoryKPI.inventoryTurnover(COGS(), averageInventory());
  }

  grossMarginReturnOnInvestment() {
    return InventoryKPI.gmroi(
      PeriodInformationsDatas.salesQuantityDuringPeriod(
        sales,
        saleItems,
        _startDate,
        _endDate,
      )['period_quantity_revenue'],
      COGS(),
      averageInventory(),
    );
  }

  stockToSalesRatio() {
    return InventoryKPI.stockToSalesRatio(
      PeriodInformationsDatas.startDateProductAvailableQuantity(
            sales,
            saleItems,
            widget.myInventoryHistories,
            _startDate,
          )['amount'] +
          PeriodInformationsDatas.periodSupplyQttValue(
            widget.myInventoryHistories,
            _startDate,
            _endDate,
          )['supply_cost'] -
          COGS(),
      PeriodInformationsDatas.salesQuantityDuringPeriod(
        sales,
        saleItems,
        _startDate,
        _endDate,
      )['period_quantity_revenue'],
    );
  }

  daysOfInventoryOnHand() {
    return InventoryKPI.daysOfInventoryOnHand(
      averageInventory(),
      COGS(),
      PeriodInformationsDatas.daysBetween(_startDate, _endDate),
    );
  }

  sellThroughRate() {
    return InventoryKPI.sellThroughRate(
      PeriodInformationsDatas.salesQuantityDuringPeriod(
        sales,
        saleItems,
        _startDate,
        _endDate,
      )['period_quantity_sold'],
      PeriodInformationsDatas.periodSupplyQttValue(
        widget.myInventoryHistories,
        _startDate,
        _endDate,
      )['supply_quantity'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      //height: 100,
      //color: Colors.green,
      child: BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
        listener: (context, state) {
          if (state is EmitRandomElementSuccessfully) {
            try {
              var data = (state.element as Map<String, dynamic>);
              if (data['id'] == "filter_sales_by_date") {
                setState(() {
                  _startDate = data['start_date'];
                  _endDate = data['end_date'];
                });
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 170,
                    child: Text(
                      currentKpiTitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.amber,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '$currentKpiValue',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ComponentInfoDialog(
                            title: currentKpiTitle,
                            message: inventoryKPIInfos[currentKpiTitle]!,
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.help, size: 18, color: Colors.white),
                  ),
                ],
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
                      "Gross Margin Return On Investment",
                      grossMarginReturnOnInvestment(),
                      false,
                    ),
                    //stockToSalesRatio
                    _inventoryNbInfos(
                      "Stock to sales ratio",
                      stockToSalesRatio(),
                      false,
                    ),
                    //daysOfInventoryOnHand
                    _inventoryNbInfos(
                      "Days of inventory on hand",
                      daysOfInventoryOnHand(),
                      false,
                    ),
                    //sellThroughRate
                    _inventoryNbInfos(
                      "Sell through rate",
                      sellThroughRate(),
                      false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              InventoryItemKpiChartView(
                inventory: widget.inventory,
                inventoryMetadata: widget.inventoryMetadata,
                myInventoryHistories: widget.myInventoryHistories,
                sales: sales,
                saleItems: saleItems,
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/apllication_method/inventory.kpi.dart';
import 'package:super_manager/core/apllication_method/inventory.kpi.information.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/component.info.dialog.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/extract.intervals.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/get.sub.intervals.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.item.kpi.chart.view.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/kpi.chart.widget.dart';
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
  final bool infoDisplayer;
  const InventoryRelevantNumbersView({
    super.key,
    required this.inventory,
    required this.inventoryVersions,
    required this.myInventoryHistories,
    required this.inventoryMetadata,
    this.infoDisplayer = false,
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
  late String periodicity = "days";
  late Map<String, dynamic> myPeriods = {};
  late int totalUnit = 0;
  late String currentKpiTitle;
  late double currentKpiValue;
  late List<KPIValue> kpiData;

  @override
  void initState() {
    super.initState();
    saleItems = {};
    sales = [];
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    myPeriods = getPeriods();
    totalUnit =
        widget.inventory.quantityAvailable +
        widget.inventory.quantityReserved +
        widget.inventory.quantitySold;
    currentKpiTitle = "Average inventory";
    currentKpiValue = averageInventory();
    kpiData = getKpiData();
    context.read<SaleCubit>().loadSales();
  }

  getPeriods() {
    return getSubIntervals(_startDate, _endDate, periodicity);
  }

  List<KPIValue> getKpiData() {
    List<KPIValue> data = [];
    for (var period in myPeriods.entries) {
      double value = 0.0;
      if (currentKpiTitle == 'Average inventory') {
        value = InventoryKPI.averageInventory(
          PeriodInformationsDatas.startDateProductAvailableQuantity(
            sales,
            saleItems,
            widget.myInventoryHistories,
            period.value['start'],
          )['amount'],
          PeriodInformationsDatas.endDateProductAvailableQuantity(
            sales,
            saleItems,
            widget.myInventoryHistories,
            widget.inventory,
            widget.inventoryMetadata,
            period.value['end'],
          )['amount'],
        );
      } else if (currentKpiTitle == 'Stock turn over rate') {
        value = inventoryTurnOver(period.value['start'], period.value['end']);
      } else if (currentKpiTitle == 'Gross Margin Return On Investment') {
        value = grossMarginReturnOnInvestment(
            period.value['start'], period.value['end']);
      } else if (currentKpiTitle == 'Stock to sales ratio') {
        value = stockToSalesRatio(period.value['start'], period.value['end']);
      } else if (currentKpiTitle == 'Days of inventory on hand') {
        value =
            daysOfInventoryOnHand(period.value['start'], period.value['end']);
      } else if (currentKpiTitle == 'Sell through rate') {
        value = sellThroughRate(period.value['start'], period.value['end']);
      }
      data.add(KPIValue(period.key, value));
    }
    return data;
  }

  Widget _inventoryNbInfos(
    String title,
    double value,
    bool selected,
    String unit,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentKpiTitle = title;
          currentKpiValue = value;
          kpiData = getKpiData();
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
                "${value.toString()} $unit",
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

  COGS(DateTime start, DateTime end) {
    //Cost of goods
    return PeriodInformationsDatas.startDateProductAvailableQuantity(
          sales,
          saleItems,
          widget.myInventoryHistories,
          start,
        )['amount'] +
        PeriodInformationsDatas.periodSupplyQttValue(
          widget.myInventoryHistories,
          start,
          end,
        )['supply_cost'] -
        PeriodInformationsDatas.endDateProductAvailableQuantity(
          sales,
          saleItems,
          widget.myInventoryHistories,
          widget.inventory,
          widget.inventoryMetadata,
          end,
        )['amount'];
  }

  inventoryTurnOver(DateTime start, DateTime end) {
    return InventoryKPI.inventoryTurnover(COGS(start, end), averageInventory());
  }

  grossMarginReturnOnInvestment(DateTime start, DateTime end) {
    return InventoryKPI.gmroi(
      PeriodInformationsDatas.salesQuantityDuringPeriod(
        sales,
        saleItems,
        start,
        end,
      )['period_quantity_revenue'],
      COGS(start, end),
      averageInventory(),
    );
  }

  stockToSalesRatio(DateTime start, DateTime end) {
    return InventoryKPI.stockToSalesRatio(
      averageInventory(),
      PeriodInformationsDatas.salesQuantityDuringPeriod(
        sales,
        saleItems,
        start,
        end,
      )['period_quantity_revenue'],
    );
  }

  daysOfInventoryOnHand(DateTime start, DateTime end) {
    return InventoryKPI.daysOfInventoryOnHand(
      averageInventory(),
      COGS(start, end),
      PeriodInformationsDatas.daysBetween(start, end),
    );
  }

  sellThroughRate(DateTime start, DateTime end) {
    return InventoryKPI.sellThroughRate(
      PeriodInformationsDatas.salesQuantityDuringPeriod(
        sales,
        saleItems,
        start,
        end,
      )['period_quantity_sold'],
      PeriodInformationsDatas.periodSupplyQttValue(
            widget.myInventoryHistories,
            start,
            end,
          )['supply_quantity'] +
          PeriodInformationsDatas.startDateProductAvailableQuantity(
            sales,
            saleItems,
            widget.myInventoryHistories,
            start,
          )['start_date_quantity'],
    );
  }

  emitKPI() {
    context.read<WidgetManipulatorCubit>().emitRandomElement({
      'id': "inventory_kpi",
      "inv_id": widget.inventory.id,
      "datas": {
        'totalAvgInventory': averageInventory(),
        'totalStockTurnOver': inventoryTurnOver(_startDate, _endDate),
        'totalGrossMarginReturnOnInv':
            grossMarginReturnOnInvestment(_startDate, _endDate),
        'totalStockToSalesRatio': stockToSalesRatio(_startDate, _endDate),
        'totalDaysOfInvOnHand': daysOfInventoryOnHand(_startDate, _endDate),
        'totalSellThroughRate': sellThroughRate(_startDate, _endDate),
        'COGS': COGS(_startDate, _endDate),
        'period_days': PeriodInformationsDatas.daysBetween(
          _startDate,
          _endDate,
        ),
        'period_amount_revenu':
            PeriodInformationsDatas.salesQuantityDuringPeriod(
              sales,
              saleItems,
              _startDate,
              _endDate,
            )['period_quantity_revenue'],
        "period_stock_value":
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
            COGS(_startDate, _endDate),
        'unitsSold': PeriodInformationsDatas.salesQuantityDuringPeriod(
          sales,
          saleItems,
          _startDate,
          _endDate,
        )['period_quantity_sold'],
        'unitsReceive': PeriodInformationsDatas.periodSupplyQttValue(
          widget.myInventoryHistories,
          _startDate,
          _endDate,
        )['supply_quantity'],
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
        listener: (context, state) {
          if (state is EmitRandomElementSuccessfully) {
            try {
              var data = (state.element as Map<String, dynamic>);
              if (data['id'] == "filter_sales_by_date") {
                setState(() {
                  _startDate = data['start_date'];
                  _endDate = data['end_date'];
                  periodicity = data['periodicity'];
                  myPeriods = getPeriods();
                  kpiData = getKpiData();
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
                    if (widget.infoDisplayer) {
                      emitKPI();
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
              !widget.infoDisplayer
                  ? Column(
                      children: [
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
                              currentKpiValue.toStringAsFixed(2),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ComponentInfoDialog(
                                      title: currentKpiTitle,
                                      message:
                                          inventoryKPIInfos[currentKpiTitle]!,
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.help,
                                size: 18,
                                color: Colors.white,
                              ),
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
                                "DH",
                              ),
                              _inventoryNbInfos(
                                "Stock turn over rate",
                                inventoryTurnOver(_startDate, _endDate),
                                false,
                                "",
                              ),
                              _inventoryNbInfos(
                                "Gross Margin Return On Investment",
                                grossMarginReturnOnInvestment(
                                    _startDate, _endDate),
                                false,
                                "DH",
                              ),
                              //stockToSalesRatio
                              _inventoryNbInfos(
                                "Stock to sales ratio",
                                stockToSalesRatio(_startDate, _endDate),
                                false,
                                "",
                              ),
                              //daysOfInventoryOnHand
                              _inventoryNbInfos(
                                "Days of inventory on hand",
                                daysOfInventoryOnHand(_startDate, _endDate),
                                false,
                                "D",
                              ),
                              //sellThroughRate
                              _inventoryNbInfos(
                                "Sell through rate",
                                sellThroughRate(_startDate, _endDate),
                                false,
                                "%",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ExtractIntervals(
                          startDate: _startDate,
                          endDate: _endDate,
                        ),
                        InventoryItemKpiChartView(
                          kpiData: kpiData,
                          chartTitle: currentKpiTitle,
                        ),
                      ],
                    )
                  : SizedBox(),
            ],
          );
        },
      ),
    );
  }
}

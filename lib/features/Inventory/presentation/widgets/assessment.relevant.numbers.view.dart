import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/apllication_method/inventory.kpi.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/period.informations.datas.dart';

import '../../../../core/apllication_method/inventory.kpi.information.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import 'assessment.kpi.chart.view.dart';
import 'component.info.dialog.dart';

class AssessmentRelevantNumbersView extends StatefulWidget {
  const AssessmentRelevantNumbersView({super.key});

  @override
  State<AssessmentRelevantNumbersView> createState() =>
      _AssessmentRelevantNumbersViewState();
}

class _AssessmentRelevantNumbersViewState
    extends State<AssessmentRelevantNumbersView> {
  late String currentKpiTitle;
  late double currentKpiValue;
  late DateTime _startDate;
  late DateTime _endDate;
  late Set<Map<String, dynamic>> avgInventorySet = {};
  late Set<Map<String, dynamic>> stockTurnOverSet = {};
  late Set<Map<String, dynamic>> grossMarginReturnOnInvSet = {};
  late Set<Map<String, dynamic>> stockToSalesRatioSet = {};
  late Set<Map<String, dynamic>> daysOfInvOnHandSet = {};
  late Set<Map<String, dynamic>> sellThroughRateSet = {};
  late Set<Map<String, dynamic>> periodsAmountSales = {};
  late Set<Map<String, dynamic>> periodsStockValue = {};
  late Set<Map<String, dynamic>> COGSSet = {};
  late Set<Map<String, dynamic>> unitsSoldSet = {};
  late Set<Map<String, dynamic>> unitsReceiveSet = {};

  late double totalAvgInventory = 0;
  late double totalStockTurnOver = 0;
  late double totalGrossMarginReturnOnInv = 0;
  late double totalStockToSalesRatio = 0;
  late double totalDaysOfInvOnHand = 0;
  late double totalSellThroughRate = 0;
  late double totalPeriodAmountRevenu = 0;
  late double totalPeriodStockValue = 0;
  late double totalCOGS = 0;
  late int totalUnitSold = 0;
  late int totalUnitsReceive = 0;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    currentKpiTitle = "Average inventory";
    currentKpiValue = 0;
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

  calculateKPI(dt) {
    return dt.map((x) => x.values.first).toList().reduce((a, b) => a + b);
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
              } else if (data['id'] == 'inventory_kpi') {
                setState(() {
                  avgInventorySet.add({
                    data["inv_id"]: data["datas"]["totalAvgInventory"],
                  });
                  totalAvgInventory = calculateKPI(avgInventorySet);
                  stockTurnOverSet.add({
                    data["inv_id"]: data["datas"]["totalStockTurnOver"],
                  });
                  totalStockTurnOver = calculateKPI(stockTurnOverSet);
                  grossMarginReturnOnInvSet.add({
                    data["inv_id"]:
                        data["datas"]["totalGrossMarginReturnOnInv"],
                  });
                  totalGrossMarginReturnOnInv = calculateKPI(
                    grossMarginReturnOnInvSet,
                  );
                  stockToSalesRatioSet.add({
                    data["inv_id"]: data["datas"]["totalStockToSalesRatio"],
                  });
                  totalStockToSalesRatio = calculateKPI(stockToSalesRatioSet);
                  daysOfInvOnHandSet.add({
                    data["inv_id"]: data["datas"]["totalDaysOfInvOnHand"],
                  });
                  totalDaysOfInvOnHand = calculateKPI(daysOfInvOnHandSet);
                  periodsAmountSales.add({
                    data["inv_id"]: data["datas"]["period_amount_revenu"],
                  });
                  totalPeriodAmountRevenu = calculateKPI(periodsAmountSales);
                  periodsStockValue.add({
                    data["inv_id"]: data["datas"]["period_stock_value"],
                  });
                  totalPeriodStockValue = calculateKPI(periodsStockValue);
                  COGSSet.add({data["inv_id"]: data["datas"]["COGS"]});
                  totalCOGS = calculateKPI(COGSSet);
                  unitsSoldSet.add({
                    data["inv_id"]: data["datas"]["unitsSold"],
                  });
                  totalUnitSold = calculateKPI(unitsSoldSet);
                  unitsReceiveSet.add({
                    data["inv_id"]: data["datas"]["unitsReceive"],
                  });
                  totalUnitsReceive = calculateKPI(unitsReceiveSet);
                  totalSellThroughRate = InventoryKPI.sellThroughRate(
                    totalUnitSold,
                    totalUnitsReceive,
                  );
                });
              }
            } catch (e) {
              print(e.toString());
            }
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    '$currentKpiValue',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 24,
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
                      totalAvgInventory,
                      false,
                    ),
                    _inventoryNbInfos(
                      "Stock turn over rate",
                      totalStockTurnOver,
                      false,
                    ),
                    _inventoryNbInfos(
                      "Gross Margin Return On Investment",
                      totalGrossMarginReturnOnInv,
                      false,
                    ),
                    //stockToSalesRatio
                    _inventoryNbInfos(
                      "Stock to sales ratio",
                      InventoryKPI.stockToSalesRatio(
                        totalPeriodStockValue,
                        totalPeriodAmountRevenu,
                      ),
                      false,
                    ),
                    //daysOfInventoryOnHand
                    _inventoryNbInfos(
                      "Days of inventory on hand",
                      InventoryKPI.daysOfInventoryOnHand(
                        totalAvgInventory,
                        totalCOGS,
                        PeriodInformationsDatas.daysBetween(
                          _startDate,
                          _endDate,
                        ),
                      ),
                      false,
                    ),
                    //sellThroughRate
                    _inventoryNbInfos(
                      "Sell through rate",
                      totalSellThroughRate,
                      false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              AssessmentKpiChartView(),
            ],
          );
        },
      ),
    );
  }
}

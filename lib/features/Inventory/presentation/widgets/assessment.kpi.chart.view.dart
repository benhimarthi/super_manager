import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/apllication_method/inventory.kpi.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import 'kpi.chart.widget.dart';

class AssessmentKpiChartView extends StatefulWidget {
  const AssessmentKpiChartView({super.key});

  @override
  State<AssessmentKpiChartView> createState() => _AssessmentKpiChartViewState();
}

class _AssessmentKpiChartViewState extends State<AssessmentKpiChartView> {
  late DateTime startDate = DateTime.now();
  late DateTime endDate = DateTime.now();
  late String periodicity = "days";

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

  late List<KPIValue> totalAvgInventory = [];
  late List<KPIValue> totalStockTurnOver = [];
  late List<KPIValue> totalGrossMarginReturnOnInv = [];
  late List<KPIValue> totalStockToSalesRatio = [];
  late List<KPIValue> totalDaysOfInvOnHand = [];
  late List<KPIValue> totalSellThroughRate = [];
  late List<KPIValue> totalPeriodAmountRevenu = [];
  late List<KPIValue> totalPeriodStockValue = [];
  late List<KPIValue> totalCOGS = [];
  late List<KPIValue> totalUnitSold = [];
  late List<KPIValue> totalUnitsReceive = [];

  changeKpi(String kpiTitle) {
    switch (kpiTitle) {
      case "Average inventory":
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "change_chart_kpi_data",
          "data": totalAvgInventory,
        });
        break;
      case "Stock turn over rate":
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "change_chart_kpi_data",
          "data": totalStockTurnOver,
        });
        break;
      case "Gross Margin Return On Investment":
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "change_chart_kpi_data",
          "data": totalGrossMarginReturnOnInv,
        });
        break;
      case "Stock to sales ratio":
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "change_chart_kpi_data",
          "data": totalStockToSalesRatio,
        });
        break;
      case "Days of inventory on hand":
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "change_chart_kpi_data",
          "data": totalDaysOfInvOnHand,
        });
        break;
      case "Sell through rate":
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "change_chart_kpi_data",
          "data": totalSellThroughRate,
        });
        break;
    }
  }

  List<KPIValue> calculateKPI(dt) {
    List<List<KPIValue>> value = dt.map((x) => x.values).toList();
    value.sort((a, b) => a.length.compareTo(b.length));
    List<KPIValue> longestChain = value.last;
    List<KPIValue> result = [];
    for (String n in longestChain.map((x) => x.label).toList()) {
      List<KPIValue?> currentDateData = value
          .map((x) => x.where((i) => i.label == n).firstOrNull)
          .toList()
          .where((x) => x != null)
          .toList();
      result.add(
        KPIValue(
          n,
          currentDateData.map((x) => x!.value).toList().reduce((a, b) => a + b),
        ),
      );
    }
    return result;
  }

  totSellThroughRate(
    List<KPIValue> totalUnitSold,
    List<KPIValue> totalUnitReceive,
  ) {
    int cnt = 0;
    for (var n in totalUnitSold) {
      totalSellThroughRate.add(
        KPIValue(
          n.label,
          InventoryKPI.sellThroughRate(
            int.parse(n.value.toString()),
            int.parse(totalUnitReceive[cnt].value.toString()),
          ),
        ),
      );
      cnt++;
    }
  }

  daysOfInvOnHand(List<KPIValue> totAvgInv, List<KPIValue> totCOGS) {
    int cnt = 0;
    int periodDays = 1;
    switch (periodicity) {
      case "days":
        periodDays = 1;
        break;
      case "weeks":
        periodDays = 7;
      case "months":
        periodDays = 30;
      case "years":
        periodDays = 360;
      default:
    }
    for (var n in totAvgInv) {
      totalDaysOfInvOnHand.add(
        KPIValue(
          n.label,
          InventoryKPI.daysOfInventoryOnHand(
            n.value,
            totCOGS[cnt].value,
            periodDays,
          ),
        ),
      );
      cnt++;
    }
  }

  stockToSalesRatio(
    List<KPIValue> totPeriodStockValue,
    List<KPIValue> totPeriodAmountRev,
  ) {
    int cnt = 0;
    for (var n in totPeriodStockValue) {
      totalStockToSalesRatio.add(
        KPIValue(
          n.label,
          InventoryKPI.stockToSalesRatio(
            n.value,
            totPeriodAmountRev[cnt].value,
          ),
        ),
      );
    }
    cnt++;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
      listener: (context, state) {
        if (state is EmitRandomElementSuccessfully) {
          try {
            var data = (state.element as Map<String, dynamic>);
            if (data['id'] == "filter_sales_by_date") {
              setState(() {
                startDate = data['start_date'];
                endDate = data['end_date'];
              });
            } else if (data['id'] == 'select_chart_periodicity') {
              setState(() {
                periodicity = data['periodicity'];
              });
            } else if (data['id'] == "select_inventory_kpi") {
              changeKpi(data['kpi']);
            } else if (data['id'] == 'emit_chart_kpi_data') {
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
                  data["inv_id"]: data["datas"]["totalGrossMarginReturnOnInv"],
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
                unitsSoldSet.add({data["inv_id"]: data["datas"]["unitsSold"]});
                totalUnitSold = calculateKPI(unitsSoldSet);
                unitsReceiveSet.add({
                  data["inv_id"]: data["datas"]["unitsReceive"],
                });
                totalUnitsReceive = calculateKPI(unitsReceiveSet);
                print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@**");
                totSellThroughRate(totalUnitSold, totalUnitsReceive);
                daysOfInvOnHand(totalAvgInventory, totalCOGS);
                stockToSalesRatio(
                  totalPeriodStockValue,
                  totalPeriodAmountRevenu,
                );
              });
            }
          } catch (e) {}
        }
      },
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 250,
          //color: Colors.amber,
          child: KpiChartWidget(
            kpiData: [
              KPIValue(DateTime(2025, 08, 01).toString(), 100.0),
              KPIValue(DateTime(2025, 08, 02).toString(), 10.0),
              KPIValue("val3", 20.0),
              KPIValue("val4", 50.0),
              KPIValue("val5", 15.0),
              KPIValue("val6", 06.0),
              KPIValue("val7", 66.0),
              KPIValue("val8", 100.0),
              KPIValue("val9", 250.0),
            ],
            chartTitle: "chart title",
          ),
        );
      },
    );
  }
}

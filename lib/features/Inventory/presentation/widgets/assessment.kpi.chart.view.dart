import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import 'kpi.chart.widget.dart';

class AssessmentKpiChartView extends StatefulWidget {
  const AssessmentKpiChartView({super.key});

  @override
  State<AssessmentKpiChartView> createState() => _AssessmentKpiChartViewState();
}

class _AssessmentKpiChartViewState extends State<AssessmentKpiChartView> {
  late Set<KPIValue> totalAvgInventory = {};
  late Set<KPIValue> totalStockTurnOver = {};
  late Set<KPIValue> totalGrossMarginReturnOnInv = {};
  late Set<KPIValue> totalStockToSalesRatio = {};
  late Set<KPIValue> totalDaysOfInvOnHand = {};
  late Set<KPIValue> totalSellThroughRate = {};
  late DateTime startDate = DateTime.now();
  late DateTime endDate = DateTime.now();
  late String periodicity = "days";

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

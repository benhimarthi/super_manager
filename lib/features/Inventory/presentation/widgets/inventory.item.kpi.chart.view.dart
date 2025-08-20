import 'package:flutter/material.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/kpi.chart.widget.dart';

class InventoryItemKpiChartView extends StatefulWidget {
  const InventoryItemKpiChartView({super.key});

  @override
  State<InventoryItemKpiChartView> createState() =>
      _InventoryItemKpiChartViewState();
}

class _InventoryItemKpiChartViewState extends State<InventoryItemKpiChartView> {
  @override
  Widget build(BuildContext context) {
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
  }
}

import 'package:flutter/material.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/kpi.chart.widget.dart';

class InventoryItemKpiChartView extends StatelessWidget {
  final List<KPIValue> kpiData;
  final String chartTitle;

  const InventoryItemKpiChartView({
    super.key,
    required this.kpiData,
    required this.chartTitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: KpiChartWidget(
        kpiData: kpiData,
        chartTitle: chartTitle,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;

enum ChartType { BarChart, PieChart, LineChart }

class KpiChartWidget extends StatefulWidget {
  final List<KPIValue> kpiData; // Assume your data is already filtered by KPI
  final String chartTitle;

  const KpiChartWidget({required this.kpiData, required this.chartTitle});

  @override
  _KpiChartWidgetState createState() => _KpiChartWidgetState();
}

class _KpiChartWidgetState extends State<KpiChartWidget> {
  DateTime? _startDate;
  DateTime? _endDate;
  ChartType _selectedChartType = ChartType.BarChart;

  Future<void> _pickDate(bool isStart) async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        // Optionally: filter data here or trigger callback
      });
    }
  }

  Widget _buildChart() {
    // The data should be filtered for the selected period before this step.
    switch (_selectedChartType) {
      case ChartType.PieChart:
        return charts.PieChart(_createSeries(), animate: true);
      case ChartType.LineChart:
        return charts.LineChart(
          _createSeries().cast<charts.Series<dynamic, num>>(),
          animate: true,
        );
      default:
        return charts.BarChart(_createSeries(), animate: true);
    }
  }

  List<charts.Series<KPIValue, String>> _createSeries() {
    return [
      charts.Series<KPIValue, String>(
        id: 'KPI',
        domainFn: (KPIValue kpi, _) => kpi.label,
        measureFn: (KPIValue kpi, _) => kpi.value,
        data: widget.kpiData, // Must be filtered by date range if needed.
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _pickDate(true),
              child: Text(
                _startDate == null
                    ? 'Start Date'
                    : _startDate.toString().split(' ')[0],
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _pickDate(false),
              child: Text(
                _endDate == null
                    ? 'End Date'
                    : _endDate.toString().split(' ')[0],
              ),
            ),
            SizedBox(width: 16),
            DropdownButton<ChartType>(
              value: _selectedChartType,
              items: ChartType.values.map((ChartType value) {
                return DropdownMenuItem<ChartType>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
              onChanged: (ChartType? newType) {
                if (newType != null) {
                  setState(() => _selectedChartType = newType);
                }
              },
            ),
          ],
        ),
        Expanded(child: _buildChart()),
      ],
    );
  }
}

// Sample data model for KPI values
class KPIValue {
  final String label;
  final double value;
  KPIValue(this.label, this.value);
}

import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';

enum ChartType { barChart, pieChart, lineChart }

enum Periodicity { days, weeks, months, years }

class KpiChartWidget extends StatefulWidget {
  final List<KPIValue> kpiData; // Assume your data is already filtered by KPI
  final String chartTitle;

  const KpiChartWidget({
    super.key,
    required this.kpiData,
    required this.chartTitle,
  });

  @override
  _KpiChartWidgetState createState() => _KpiChartWidgetState();
}

class _KpiChartWidgetState extends State<KpiChartWidget> {
  ChartType _selectedChartType = ChartType.barChart;
  Periodicity _selectedPeriod = Periodicity.days;
  late List<KPIValue> kpiData;

  @override
  @override
  void initState() {
    super.initState();
    kpiData = widget.kpiData;
  }

  Widget _buildChart() {
    // The data should be filtered for the selected period before this step.
    switch (_selectedChartType) {
      case ChartType.pieChart:
        return charts.PieChart(_createPieSeries(), animate: true);
      case ChartType.lineChart:
        return charts.LineChart(
          _createSeries().cast<charts.Series<dynamic, num>>(),
          animate: true,
          behaviors: [
            charts.SeriesLegend(
              position: charts
                  .BehaviorPosition
                  .bottom, // Legend position: bottom, top, start, end
              horizontalFirst:
                  false, // Whether legend is laid out horizontally first
              cellPadding: EdgeInsets.only(
                right: 4.0,
                bottom: 4.0,
              ), // Padding around legend entries
              showMeasures: true, // Show measure values in legend
              legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
              entryTextStyle: charts.TextStyleSpec(
                color: charts.MaterialPalette.white,
              ),
              // Other options to customize legend appearance
            ),
          ],
        );
      default:
        return charts.BarChart(
          _createSeries().cast<charts.Series<dynamic, String>>(),
          animate: true,
          behaviors: [
            charts.SeriesLegend(
              position: charts
                  .BehaviorPosition
                  .bottom, // Legend position: bottom, top, start, end
              horizontalFirst:
                  false, // Whether legend is laid out horizontally first
              cellPadding: EdgeInsets.only(
                right: 4.0,
                bottom: 4.0,
              ), // Padding around legend entries
              showMeasures: true, // Show measure values in legend
              legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
              // Other options to customize legend appearance
              entryTextStyle: charts.TextStyleSpec(
                color: charts.MaterialPalette.white,
              ),
            ),
          ],
        );
    }
  }

  List<charts.Series<KPIValue, Object>> _createPieSeries() {
    return [
      charts.Series<KPIValue, Object>(
        id: 'KPI',
        domainFn: (KPIValue kpi, _) => kpi.label,
        measureFn: (KPIValue kpi, _) => kpi.value,
        data: kpiData,
        //colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
    ];
  }

  List<charts.Series<KPIValue, dynamic>> _createSeries() {
    if (_selectedChartType == ChartType.lineChart) {
      // For line chart, x-axis (domain) must be num or DateTime
      return [
        charts.Series<KPIValue, num>(
          id: 'KPI',
          domainFn: (KPIValue kpi, int? i) => i!,
          measureFn: (KPIValue kpi, _) => kpi.value,
          data: kpiData,
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        ),
      ];
    } else {
      // For bar/pie chart, domain can be String (label)
      return [
        charts.Series<KPIValue, String>(
          id: 'KPI',
          domainFn: (KPIValue kpi, _) => kpi.label,
          measureFn: (KPIValue kpi, _) => kpi.value,
          data: kpiData,
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
      listener: (context, state) {
        if (state is EmitRandomElementSuccessfully) {
          try {
            var data = (state.element as Map<String, dynamic>);
            if (data['id'] == "change_chart_kpi_data") {
              setState(() {
                kpiData = data['data'];
              });
            }
            // ignore: empty_catches
          } catch (e) {}
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Row(
              children: [
                SizedBox(width: 16),
                DropdownButton<ChartType>(
                  value: _selectedChartType,
                  underline: SizedBox(),
                  items: ChartType.values.map((ChartType value) {
                    return DropdownMenuItem<ChartType>(
                      value: value,
                      child: Text(
                        value.toString().split('.').last,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    );
                  }).toList(),
                  onChanged: (ChartType? newType) {
                    if (newType != null) {
                      setState(() => _selectedChartType = newType);
                    }
                  },
                ),
                SizedBox(width: 16),
                DropdownButton<Periodicity>(
                  value: _selectedPeriod,
                  underline: SizedBox(),
                  items: Periodicity.values.map((Periodicity value) {
                    return DropdownMenuItem<Periodicity>(
                      value: value,
                      child: Text(
                        value.toString().split('.').last,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    );
                  }).toList(),
                  onChanged: (Periodicity? newType) {
                    if (newType != null) {
                      setState(() => _selectedPeriod = newType);
                      context.read<WidgetManipulatorCubit>().emitRandomElement({
                        "id": "select_chart_periodicity",
                        "periodicity": newType.name,
                      });
                    }
                  },
                ),
              ],
            ),
            Expanded(child: _buildChart()),
          ],
        );
      },
    );
  }
}

// Sample data model for KPI values
class KPIValue {
  final String label;
  final double value;
  KPIValue(this.label, this.value);
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/get.sub.intervals.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/kpi.chart.widget.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/period.informations.datas.dart';
import 'package:super_manager/features/sale/domain/entities/sale.dart';
import 'package:super_manager/features/sale_item/domain/entities/sale.item.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

import '../../../../core/apllication_method/inventory.kpi.dart';
import '../../../action_history/domain/entities/action.history.dart';
import '../../../inventory_meta_data/domain/entities/inventory.meta.data.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import '../../domain/entities/inventory.dart';

class InventoryItemKpiChartView extends StatefulWidget {
  final Inventory inventory;
  final InventoryMetadata inventoryMetadata;
  final List<ActionHistory> myInventoryHistories;
  final List<Sale> sales;
  final Set<SaleItem> saleItems;
  const InventoryItemKpiChartView({
    super.key,
    required this.inventory,
    required this.inventoryMetadata,
    required this.myInventoryHistories,
    required this.sales,
    required this.saleItems,
  });

  @override
  State<InventoryItemKpiChartView> createState() =>
      _InventoryItemKpiChartViewState();
}

class _InventoryItemKpiChartViewState extends State<InventoryItemKpiChartView> {
  late DateTime startDate = DateTime.now();
  late DateTime endDate = DateTime.now();
  late String periodicity = "days";
  late Map<String, dynamic> myPeriods = {};

  getPeriods() {
    return getSubIntervals(startDate, endDate, periodicity);
  }

  averageInventory(DateTime startDate, DateTime endDate) {
    return InventoryKPI.averageInventory(
      PeriodInformationsDatas.startDateProductAvailableQuantity(
        widget.sales,
        widget.saleItems,
        widget.myInventoryHistories,
        startDate,
      )['amount'],
      PeriodInformationsDatas.endDateProductAvailableQuantity(
        widget.sales,
        widget.saleItems,
        widget.myInventoryHistories,
        widget.inventory,
        widget.inventoryMetadata,
        endDate,
      )['amount'],
    );
  }

  COGS(DateTime startDate, DateTime endDate) {
    //Cost of goods
    return PeriodInformationsDatas.startDateProductAvailableQuantity(
          widget.sales,
          widget.saleItems,
          widget.myInventoryHistories,
          startDate,
        )['amount'] +
        PeriodInformationsDatas.periodSupplyQttValue(
          widget.myInventoryHistories,
          startDate,
          endDate,
        )['supply_cost'] +
        PeriodInformationsDatas.endDateProductAvailableQuantity(
          widget.sales,
          widget.saleItems,
          widget.myInventoryHistories,
          widget.inventory,
          widget.inventoryMetadata,
          endDate,
        )['amount'];
  }

  inventoryTurnOver(DateTime startDate, DateTime endDate) {
    return InventoryKPI.inventoryTurnover(
      COGS(startDate, endDate),
      averageInventory(startDate, endDate),
    );
  }

  grossMarginReturnOnInvestment(DateTime startDate, DateTime endDate) {
    return InventoryKPI.gmroi(
      PeriodInformationsDatas.salesQuantityDuringPeriod(
        widget.sales,
        widget.saleItems,
        startDate,
        endDate,
      )['period_quantity_revenue'],
      COGS(startDate, endDate),
      averageInventory(startDate, endDate),
    );
  }

  stockToSalesRatio(DateTime startDate, DateTime endDate) {
    return InventoryKPI.stockToSalesRatio(
      PeriodInformationsDatas.startDateProductAvailableQuantity(
            widget.sales,
            widget.saleItems,
            widget.myInventoryHistories,
            startDate,
          )['amount'] +
          PeriodInformationsDatas.periodSupplyQttValue(
            widget.myInventoryHistories,
            startDate,
            endDate,
          )['supply_cost'] -
          COGS(startDate, endDate),
      PeriodInformationsDatas.salesQuantityDuringPeriod(
        widget.sales,
        widget.saleItems,
        startDate,
        endDate,
      )['period_quantity_revenue'],
    );
  }

  daysOfInventoryOnHand(DateTime startDate, DateTime endDate) {
    return InventoryKPI.daysOfInventoryOnHand(
      averageInventory(startDate, endDate),
      COGS(startDate, endDate),
      PeriodInformationsDatas.daysBetween(startDate, endDate),
    );
  }

  sellThroughRate(DateTime startDate, DateTime endDate) {
    return InventoryKPI.sellThroughRate(
      PeriodInformationsDatas.salesQuantityDuringPeriod(
        widget.sales,
        widget.saleItems,
        startDate,
        endDate,
      )['period_quantity_sold'],
      PeriodInformationsDatas.periodSupplyQttValue(
        widget.myInventoryHistories,
        startDate,
        endDate,
      )['supply_quantity'],
    );
  }

  calculatePediodKPI(Function mt) {
    if (myPeriods.isNotEmpty) {
      return List.generate(myPeriods['count'], (x) {
        final currentVal = myPeriods['subIntervals'][x];
        return KPIValue(
          '${currentVal['start'].toString()} - ${currentVal['end'].toString()}',
          mt(currentVal['start'], currentVal['end']),
        );
      });
    } else {
      return [];
    }
  }

  changeKpi(String kpiTitle) {
    switch (kpiTitle) {
      case "Average inventory":
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "change_chart_kpi_data",
          "inv_id": widget.inventory.id,
          "data": calculatePediodKPI(averageInventory),
        });
        break;
      case "Stock turn over rate":
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "change_chart_kpi_data",
          "inv_id": widget.inventory.id,
          "data": calculatePediodKPI(inventoryTurnOver),
        });
        break;
      case "Gross Margin Return On Investment":
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "change_chart_kpi_data",
          "inv_id": widget.inventory.id,
          "data": calculatePediodKPI(grossMarginReturnOnInvestment),
        });
        break;
      case "Stock to sales ratio":
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "change_chart_kpi_data",
          "inv_id": widget.inventory.id,
          "data": calculatePediodKPI(stockToSalesRatio),
        });
        break;
      case "Days of inventory on hand":
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "change_chart_kpi_data",
          "inv_id": widget.inventory.id,
          "data": calculatePediodKPI(daysOfInventoryOnHand),
        });
        break;
      case "Sell through rate":
        context.read<WidgetManipulatorCubit>().emitRandomElement({
          "id": "change_chart_kpi_data",
          "inv_id": widget.inventory.id,
          "data": calculatePediodKPI(sellThroughRate),
        });
        break;
    }
  }

  emitChartKPI() {
    context.read<WidgetManipulatorCubit>().emitRandomElement({
      "id": "change_chart_kpi_data",
      "inv_id": widget.inventory.id,
      "data": calculatePediodKPI(averageInventory),
    });
    context.read<WidgetManipulatorCubit>().emitRandomElement({
      "id": "change_chart_kpi_data",
      "inv_id": widget.inventory.id,
      "data": calculatePediodKPI(inventoryTurnOver),
    });
    context.read<WidgetManipulatorCubit>().emitRandomElement({
      "id": "change_chart_kpi_data",
      "inv_id": widget.inventory.id,
      "data": calculatePediodKPI(grossMarginReturnOnInvestment),
    });
    context.read<WidgetManipulatorCubit>().emitRandomElement({
      "id": "change_chart_kpi_data",
      "inv_id": widget.inventory.id,
      "data": calculatePediodKPI(stockToSalesRatio),
    });
    context.read<WidgetManipulatorCubit>().emitRandomElement({
      "id": "change_chart_kpi_data",
      "inv_id": widget.inventory.id,
      "data": calculatePediodKPI(daysOfInventoryOnHand),
    });
    context.read<WidgetManipulatorCubit>().emitRandomElement({
      "id": "change_chart_kpi_data",
      "inv_id": widget.inventory.id,
      "data": calculatePediodKPI(sellThroughRate),
    });
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
                myPeriods = getPeriods();
              });
            } else if (data['id'] == 'select_chart_periodicity') {
              setState(() {
                periodicity = data['periodicity'];
                myPeriods = getPeriods();
              });
            } else if (data['id'] == "select_inventory_kpi") {
              changeKpi(data['kpi']);
            }
            // ignore: empty_catches
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

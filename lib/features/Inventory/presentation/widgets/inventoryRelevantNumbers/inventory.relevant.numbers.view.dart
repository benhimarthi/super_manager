import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/component.info.dialog.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/extract.intervals.dart';

import '../../../../../core/apllication_method/inventory.kpi.information.dart';
import '../../../../action_history/domain/entities/action.history.dart';
import '../../../../inventory_meta_data/domain/entities/inventory.meta.data.dart';
import '../../../../sale/domain/entities/sale.dart';
import '../../../../sale/presentation/cubit/sale.cubit.dart';
import '../../../../sale/presentation/cubit/sale.state.dart';
import '../../../../sale_item/domain/entities/sale.item.dart';
import '../../../../sale_item/presentation/cubit/sale.item.cubit.dart';
import '../../../../sale_item/presentation/cubit/sale.item.state.dart';
import '../../../../widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../domain/entities/inventory.dart';
import '../get.sub.intervals.dart';
import '../inventory.item.kpi.chart.view.dart';
import '../kpi.chart.widget.dart';
import 'inventory.kpi.list.dart';
import 'inventory.kpi.service.dart';

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
  List<Sale> sales = [];
  Set<SaleItem> saleItems = {};
  late DateTime _startDate;
  late DateTime _endDate;
  late String currentKpiTitle;
  late String periodicity = "days";
  late double currentKpiValue;
  late List<Map<String, dynamic>> kpis;
  late Map<String, dynamic> myPeriods = {};
  InventoryKpiService? _kpiService;
  late List<KPIValue> kpiData;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    currentKpiTitle = "Average inventory";
    currentKpiValue = 0;
    kpis = [];
    kpiData = [];
    myPeriods = getPeriods();
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
        value = _kpiService!.averageInventory(_startDate, _endDate);
      } else if (currentKpiTitle == 'Stock turn over rate') {
        value = _kpiService!.inventoryTurnOver(_startDate, _endDate);
      } else if (currentKpiTitle == 'Gross Margin Return On Investment') {
        value = _kpiService!.grossMarginReturnOnInvestment(
          _startDate,
          _endDate,
        );
      } else if (currentKpiTitle == 'Stock to sales ratio') {
        value = _kpiService!.stockToSalesRatio(_startDate, _endDate);
      } else if (currentKpiTitle == 'Days of inventory on hand') {
        value = _kpiService!.daysOfInventoryOnHand(_startDate, _endDate);
      } else if (currentKpiTitle == 'Sell through rate') {
        value = _kpiService!.sellThroughRate(_startDate, _endDate);
      }
      data.add(KPIValue(period.key, value));
    }
    return data;
  }

  void _updateKpiService() {
    if (sales.isEmpty) return;

    _kpiService = InventoryKpiService(
      inventory: widget.inventory,
      inventoryMetadata: widget.inventoryMetadata,
      histories: widget.myInventoryHistories,
      sales: sales,
      saleItems: saleItems,
    );

    setState(() {
      kpis = [
        {
          "title": "Average inventory",
          "value": _kpiService!.averageInventory(_startDate, _endDate),
          "unit": "DH",
        },
        {
          "title": "Stock turn over rate",
          "value": _kpiService!.inventoryTurnOver(_startDate, _endDate),
          "unit": "",
        },
        {
          "title": "Gross Margin Return On Investment",
          "value": _kpiService!.grossMarginReturnOnInvestment(
            _startDate,
            _endDate,
          ),
          "unit": "DH",
        },
        {
          "title": "Stock to sales ratio",
          "value": _kpiService!.stockToSalesRatio(_startDate, _endDate),
          "unit": "",
        },
        {
          "title": "Days of inventory on hand",
          "value": _kpiService!.daysOfInventoryOnHand(_startDate, _endDate),
          "unit": "D",
        },
        {
          "title": "Sell through rate",
          "value": _kpiService!.sellThroughRate(_startDate, _endDate),
          "unit": "%",
        },
      ];

      currentKpiValue = kpis.firstWhere(
        (k) => k['title'] == currentKpiTitle,
      )['value'];
      kpiData = getKpiData();
    });
  }

  void _onKpiSelected(String title) {
    setState(() {
      currentKpiTitle = title;
      currentKpiValue = kpis.firstWhere((k) => k['title'] == title)['value'];
    });
    context.read<WidgetManipulatorCubit>().emitRandomElement({
      "id": "select_inventory_kpi",
      "kpi": title,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          BlocConsumer<SaleCubit, SaleState>(
            listener: (context, state) {
              if (state is SaleManagerLoaded) {
                sales = state.saleList;
                for (var n in sales) {
                  context.read<SaleItemCubit>().loadSaleItems(n.id);
                }
                _updateKpiService();
              }
            },
            builder: (_, __) => Container(),
          ),
          BlocConsumer<SaleItemCubit, SaleItemState>(
            listener: (context, state) {
              if (state is SaleItemManagerLoaded) {
                saleItems.addAll(
                  state.saleItemList.where(
                    (item) => item.productId == widget.inventory.productId,
                  ),
                );
                _updateKpiService();
              }
            },
            builder: (_, __) => Container(),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  currentKpiTitle,
                  style: const TextStyle(color: Colors.amber),
                ),
              ),
              Text(
                currentKpiValue.toStringAsFixed(2),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ComponentInfoDialog(
                    title: currentKpiTitle,
                    message: inventoryKPIInfos[currentKpiTitle]!,
                  ),
                ),
                icon: const Icon(Icons.help, color: Colors.white),
              ),
            ],
          ),
          InventoryKpiList(
            selectedKpi: currentKpiTitle,
            kpis: kpis,
            onKpiSelected: _onKpiSelected,
          ),
          const SizedBox(height: 10),
          ExtractIntervals(startDate: _startDate, endDate: _endDate),
          if (_kpiService != null)
            InventoryItemKpiChartView(
              kpiData : kpiData, // You can integrate _kpiService!.kpiDataList if needed
              chartTitle : currentKpiTitle,
            ),
        ],
      ),
    );
  }
}

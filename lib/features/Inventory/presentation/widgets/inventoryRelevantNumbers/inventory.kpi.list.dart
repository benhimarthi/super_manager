import 'package:flutter/material.dart';

import 'kpi.item.widget.dart';

class InventoryKpiList extends StatelessWidget {
  final String selectedKpi;
  final List<Map<String, dynamic>> kpis;
  final void Function(String title) onKpiSelected;

  const InventoryKpiList({
    super.key,
    required this.selectedKpi,
    required this.kpis,
    required this.onKpiSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemCount: kpis.length,
        itemBuilder: (context, i) {
          final kpi = kpis[i];
          return KpiItemWidget(
            title: kpi['title'],
            value: kpi['value'],
            unit: kpi['unit'],
            selected: selectedKpi == kpi['title'],
            onTap: () => onKpiSelected(kpi['title']),
          );
        },
      ),
    );
  }
}

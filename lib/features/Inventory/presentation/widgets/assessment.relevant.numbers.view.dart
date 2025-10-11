/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/service/depenedancy.injection.dart';

import '../../../../core/apllication_method/inventory.kpi.information.dart';
import '../cubit/assessment_kpi_cubit.dart';
import 'assessment.kpi.chart.view.dart';
import 'component.info.dialog.dart';

class AssessmentRelevantNumbersView extends StatelessWidget {
  const AssessmentRelevantNumbersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AssessmentKpiCubit>()..calculateGlobalKpis(),
      child: const _AssessmentRelevantNumbersView(),
    );
  }
}

class _AssessmentRelevantNumbersView extends StatelessWidget {
  const _AssessmentRelevantNumbersView();

  Widget _inventoryNbInfos(BuildContext context, String title, double value) {
    return GestureDetector(
      onTap: () {
        context.read<AssessmentKpiCubit>().changeKpiTitle(title);
      },
      child: BlocBuilder<AssessmentKpiCubit, AssessmentKpiState>(
        builder: (context, state) {
          if (state is AssessmentKpiLoaded) {
            return Container(
              height: 60,
              width: 100,
              padding: const EdgeInsets.all(3),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: state.currentKpiTitle == title
                      ? Colors.green
                      : const Color.fromARGB(255, 88, 88, 88),
                  width: state.currentKpiTitle == title ? 5 : 2,
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
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 55,
                    child: Text(
                      value.toStringAsFixed(2),
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
            );
          }
          return const SizedBox.shrink(); // Or a placeholder
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<AssessmentKpiCubit, AssessmentKpiState>(
        builder: (context, state) {
          if (state is AssessmentKpiLoading || state is AssessmentKpiInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AssessmentKpiLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 170,
                      child: Text(
                        state.currentKpiTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.amber,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      state.currentKpiValue.toStringAsFixed(2),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ComponentInfoDialog(
                              title: state.currentKpiTitle,
                              message: inventoryKPIInfos[state.currentKpiTitle] ??
                                  'No information available.',
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.help, size: 18, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _inventoryNbInfos(
                        context,
                        "Average inventory",
                        state.totalAvgInventory,
                      ),
                      _inventoryNbInfos(
                        context,
                        "Stock turn over rate",
                        state.totalStockTurnOver,
                      ),
                      _inventoryNbInfos(
                        context,
                        "Gross Margin Return On Investment",
                        state.totalGrossMarginReturnOnInv,
                      ),
                      _inventoryNbInfos(
                        context,
                        "Stock to sales ratio",
                        state.totalStockToSalesRatio,
                      ),
                      _inventoryNbInfos(
                        context,
                        "Days of inventory on hand",
                        state.totalDaysOfInvOnHand,
                      ),
                      _inventoryNbInfos(
                        context,
                        "Sell through rate",
                        state.totalSellThroughRate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const AssessmentKpiChartView(),
              ],
            );
          }
          return const Center(child: Text("An error occurred."));
        },
      ),
    );
  }
}
*/
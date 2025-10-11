/*import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/apllication_method/inventory.kpi.dart';
import '../../../Inventory/domain/usecases/get.all.inventory.dart';
import '../../../inventory_meta_data/domain/usecases/get.all.inventory.meta.data.data.dart';
import '../../../product/domain/usecases/get.all.product.dart';
import '../../../sale/domain/usecases/get.all.sale.dart';

part 'assessment_kpi_state.dart';

class AssessmentKpiCubit extends Cubit<AssessmentKpiState> {
  final GetAllInventory getAllInventory;
  final GetAllProducts getAllProduct;
  final GetAllSales getAllSale;
  final GetAllInventoryMetadata getAllInventoryMetaData;

  AssessmentKpiCubit({
    required this.getAllInventory,
    required this.getAllProduct,
    required this.getAllSale,
    required this.getAllInventoryMetaData,
  }) : super(AssessmentKpiInitial());

  Future<void> calculateGlobalKpis() async {
    emit(AssessmentKpiLoading());

    final inventoriesEither = await getAllInventory();
    final metaDataEither = await getAllInventoryMetaData();

    await inventoriesEither.fold(
      (failure) async => emit(const AssessmentKpiLoaded(
          currentKpiTitle: "Error",
          currentKpiValue: 0,
          totalAvgInventory: 0,
          totalStockTurnOver: 0,
          totalGrossMarginReturnOnInv: 0,
          totalStockToSalesRatio: 0,
          totalDaysOfInvOnHand: 0,
          totalSellThroughRate: 0)),
      (inventories) async {
        await metaDataEither.fold(
          (failure) async => emit(const AssessmentKpiLoaded(
              currentKpiTitle: "Error",
              currentKpiValue: 0,
              totalAvgInventory: 0,
              totalStockTurnOver: 0,
              totalGrossMarginReturnOnInv: 0,
              totalStockToSalesRatio: 0,
              totalDaysOfInvOnHand: 0,
              totalSellThroughRate: 0)),
          (metaDatas) async {
            double totalAvgInventory = 0;
            double totalStockTurnOver = 0;
            double totalGrossMarginReturnOnInv = 0;
            double totalStockToSalesRatio = 0;
            double totalDaysOfInvOnHand = 0;
            // Placeholder values for sell-through rate components
            int totalUnitsSold = 0; 
            int totalUnitsReceived = 0;

            for (var inventory in inventories) {
              final metaDataForInventory = metaDatas
                  .where((md) => md.inventoryId == inventory.id)
                  .toList();
              
              totalAvgInventory += InventoryKPI.averageInventory(metaDataForInventory);
              totalStockTurnOver += InventoryKPI.inventoryTurnover(metaDataForInventory);
              totalGrossMarginReturnOnInv += InventoryKPI.gmroi(metaDataForInventory);
              totalStockToSalesRatio += InventoryKPI.stockToSalesRatio(metaDataForInventory);
              totalDaysOfInvOnHand += InventoryKPI.daysOfInventoryOnHand(metaDataForInventory);
            }

            final totalSellThroughRate = InventoryKPI.sellThroughRate(totalUnitsSold, totalUnitsReceived);

            emit(AssessmentKpiLoaded(
              currentKpiTitle: 'Average inventory',
              currentKpiValue: totalAvgInventory,
              totalAvgInventory: totalAvgInventory,
              totalStockTurnOver: totalStockTurnOver,
              totalGrossMarginReturnOnInv: totalGrossMarginReturnOnInv,
              totalStockToSalesRatio: totalStockToSalesRatio,
              totalDaysOfInvOnHand: totalDaysOfInvOnHand,
              totalSellThroughRate: totalSellThroughRate,
            ));
          },
        );
      },
    );
  }

  void changeKpiTitle(String newTitle) {
    if (state is AssessmentKpiLoaded) {
      final currentState = state as AssessmentKpiLoaded;
      emit(currentState.copyWith(
        currentKpiTitle: newTitle,
        currentKpiValue: _getKpiValueByTitle(newTitle, currentState),
      ));
    }
  }

  double _getKpiValueByTitle(String title, AssessmentKpiLoaded state) {
    switch (title) {
      case "Average inventory":
        return state.totalAvgInventory;
      case "Stock turn over rate":
        return state.totalStockTurnOver;
      case "Gross Margin Return On Investment":
        return state.totalGrossMarginReturnOnInv;
      case "Stock to sales ratio":
        return state.totalStockToSalesRatio;
      case "Days of inventory on hand":
        return state.totalDaysOfInvOnHand;
      case "Sell through rate":
        return state.totalSellThroughRate;
      default:
        return 0.0;
    }
  }
}
*/

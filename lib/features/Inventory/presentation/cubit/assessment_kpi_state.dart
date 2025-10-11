/*part of 'assessment_kpi_cubit.dart';

abstract class AssessmentKpiState extends Equatable {
  const AssessmentKpiState();

  @override
  List<Object> get props => [];
}

class AssessmentKpiInitial extends AssessmentKpiState {}

class AssessmentKpiLoading extends AssessmentKpiState {}

class AssessmentKpiLoaded extends AssessmentKpiState {
  final String currentKpiTitle;
  final double currentKpiValue;
  final double totalAvgInventory;
  final double totalStockTurnOver;
  final double totalGrossMarginReturnOnInv;
  final double totalStockToSalesRatio;
  final double totalDaysOfInvOnHand;
  final double totalSellThroughRate;

  const AssessmentKpiLoaded({
    required this.currentKpiTitle,
    required this.currentKpiValue,
    required this.totalAvgInventory,
    required this.totalStockTurnOver,
    required this.totalGrossMarginReturnOnInv,
    required this.totalStockToSalesRatio,
    required this.totalDaysOfInvOnHand,
    required this.totalSellThroughRate,
  });

  @override
  List<Object> get props => [
        currentKpiTitle,
        currentKpiValue,
        totalAvgInventory,
        totalStockTurnOver,
        totalGrossMarginReturnOnInv,
        totalStockToSalesRatio,
        totalDaysOfInvOnHand,
        totalSellThroughRate,
      ];

  AssessmentKpiLoaded copyWith({
    String? currentKpiTitle,
    double? currentKpiValue,
    double? totalAvgInventory,
    double? totalStockTurnOver,
    double? totalGrossMarginReturnOnInv,
    double? totalStockToSalesRatio,
    double? totalDaysOfInvOnHand,
    double? totalSellThroughRate,
  }) {
    return AssessmentKpiLoaded(
      currentKpiTitle: currentKpiTitle ?? this.currentKpiTitle,
      currentKpiValue: currentKpiValue ?? this.currentKpiValue,
      totalAvgInventory: totalAvgInventory ?? this.totalAvgInventory,
      totalStockTurnOver: totalStockTurnOver ?? this.totalStockTurnOver,
      totalGrossMarginReturnOnInv:
          totalGrossMarginReturnOnInv ?? this.totalGrossMarginReturnOnInv,
      totalStockToSalesRatio:
          totalStockToSalesRatio ?? this.totalStockToSalesRatio,
      totalDaysOfInvOnHand: totalDaysOfInvOnHand ?? this.totalDaysOfInvOnHand,
      totalSellThroughRate: totalSellThroughRate ?? this.totalSellThroughRate,
    );
  }
}
*/

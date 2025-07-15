import 'package:equatable/equatable.dart';

class InventoryMetadata extends Equatable {
  final String id;
  final String inventoryId;
  final double costPerUnit;
  final double totalStockValue;
  final double markupPercentage;
  final double averageDailySales;
  final double stockTurnoverRate;
  final int leadTimeInDays;
  final double demandForecast;
  final double seasonalityFactor;
  final String inventorySource;
  final String createdBy;
  final String updatedBy;

  const InventoryMetadata({
    required this.id,
    required this.inventoryId,
    required this.costPerUnit,
    required this.totalStockValue,
    required this.markupPercentage,
    required this.averageDailySales,
    required this.stockTurnoverRate,
    required this.leadTimeInDays,
    required this.demandForecast,
    required this.seasonalityFactor,
    required this.inventorySource,
    required this.createdBy,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [
        id,
        inventoryId,
        costPerUnit,
        totalStockValue,
        markupPercentage,
        averageDailySales,
        stockTurnoverRate,
        leadTimeInDays,
        demandForecast,
        seasonalityFactor,
        inventorySource,
        createdBy,
        updatedBy,
      ];
}

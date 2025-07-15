import '../../domain/entities/inventory.meta.data.dart';

class InventoryMetadataModel extends InventoryMetadata {
  const InventoryMetadataModel({
    required super.id,
    required super.inventoryId,
    required super.costPerUnit,
    required super.totalStockValue,
    required super.markupPercentage,
    required super.averageDailySales,
    required super.stockTurnoverRate,
    required super.leadTimeInDays,
    required super.demandForecast,
    required super.seasonalityFactor,
    required super.inventorySource,
    required super.createdBy,
    required super.updatedBy,
  });

  factory InventoryMetadataModel.fromEntity(InventoryMetadata entity) {
    return InventoryMetadataModel(
      id: entity.id,
      inventoryId: entity.inventoryId,
      costPerUnit: entity.costPerUnit,
      totalStockValue: entity.totalStockValue,
      markupPercentage: entity.markupPercentage,
      averageDailySales: entity.averageDailySales,
      stockTurnoverRate: entity.stockTurnoverRate,
      leadTimeInDays: entity.leadTimeInDays,
      demandForecast: entity.demandForecast,
      seasonalityFactor: entity.seasonalityFactor,
      inventorySource: entity.inventorySource,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }

  InventoryMetadata toEntity() {
    return InventoryMetadata(
      id: id,
      inventoryId: inventoryId,
      costPerUnit: costPerUnit,
      totalStockValue: totalStockValue,
      markupPercentage: markupPercentage,
      averageDailySales: averageDailySales,
      stockTurnoverRate: stockTurnoverRate,
      leadTimeInDays: leadTimeInDays,
      demandForecast: demandForecast,
      seasonalityFactor: seasonalityFactor,
      inventorySource: inventorySource,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  factory InventoryMetadataModel.fromMap(Map<String, dynamic> map) {
    return InventoryMetadataModel(
      id: map['id'] as String,
      inventoryId: map['inventoryId'] as String,
      costPerUnit: (map['costPerUnit'] as num).toDouble(),
      totalStockValue: (map['totalStockValue'] as num).toDouble(),
      markupPercentage: (map['markupPercentage'] as num).toDouble(),
      averageDailySales: (map['averageDailySales'] as num).toDouble(),
      stockTurnoverRate: (map['stockTurnoverRate'] as num).toDouble(),
      leadTimeInDays: map['leadTimeInDays'] as int,
      demandForecast: (map['demandForecast'] as num).toDouble(),
      seasonalityFactor: (map['seasonalityFactor'] as num).toDouble(),
      inventorySource: map['inventorySource'] as String,
      createdBy: map['createdBy'] as String,
      updatedBy: map['updatedBy'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inventoryId': inventoryId,
      'costPerUnit': costPerUnit,
      'totalStockValue': totalStockValue,
      'markupPercentage': markupPercentage,
      'averageDailySales': averageDailySales,
      'stockTurnoverRate': stockTurnoverRate,
      'leadTimeInDays': leadTimeInDays,
      'demandForecast': demandForecast,
      'seasonalityFactor': seasonalityFactor,
      'inventorySource': inventorySource,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

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

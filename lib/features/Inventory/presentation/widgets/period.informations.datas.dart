import 'package:super_manager/features/action_history/domain/entities/action.history.dart';
import 'package:super_manager/features/inventory_meta_data/domain/entities/inventory.meta.data.dart';
import '../../../sale/domain/entities/sale.dart';
import '../../../sale_item/domain/entities/sale.item.dart';
import '../../domain/entities/inventory.dart';

class PeriodInformationsDatas {
  /// Checks if two dates are the same (ignores time)
  static bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Computes total quantity sold and revenue during a period
  static Map<String, dynamic> salesQuantityDuringPeriod(
    List<Sale> sales,
    Set<SaleItem> saleItems,
    DateTime startDate,
    DateTime endDate,
  ) {
    final periodSales = sales
        .where(
          (x) =>
              x.status == "Paid" &&
              x.date.isAfter(startDate) &&
              x.date.isBefore(endDate),
        )
        .toList();

    final periodSaleItems = saleItems
        .where((x) => periodSales.map((y) => y.id).contains(x.saleId))
        .toList();

    final saleQuantityPeriod = periodSaleItems.fold<int>(
      0,
      (sum, x) => sum + (x.quantity),
    );
    final saleRevenuePeriod = periodSaleItems.fold<double>(
      0.0,
      (sum, x) => sum + (x.quantity * x.unitPrice),
    );

    return {
      "period_quantity_sold": saleQuantityPeriod,
      "period_quantity_revenue": saleRevenuePeriod,
    };
  }

  /// Calculates product quantity and value at start date
  static Map<String, dynamic> startDateProductAvailableQuantity(
    List<Sale> sales,
    Set<SaleItem> saleItems,
    List<ActionHistory> inventoryHistories,
    DateTime startDate,
  ) {
    final previousInventories =
        inventoryHistories
            .where(
              (x) =>
                  x.timestamp.isBefore(startDate) ||
                  isSameDate(x.timestamp, startDate),
            )
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final earliestRestock = previousInventories.isNotEmpty
        ? previousInventories.last
        : null;

    if (earliestRestock != null) {
      final salesAfterRestock = sales
          .where(
            (x) =>
                x.date.isAfter(earliestRestock.timestamp) &&
                x.date.isBefore(startDate),
          )
          .toList();

      final saleItemsAfterRestock = saleItems
          .where((x) => salesAfterRestock.map((y) => y.id).contains(x.saleId))
          .toList();

      final quantitySold = saleItemsAfterRestock.fold<int>(
        0,
        (sum, x) => sum + (x.quantity),
      );

      final inventoryChanges = earliestRestock.changes['inventory'] ?? {};
      final inventoryMetaChanges =
          earliestRestock.changes['inventory_meta_data'] ?? {};

      final Map<String, dynamic>? newInventoryVersion =
          inventoryChanges['new_version'] as Map<String, dynamic>?;
      final Map<String, dynamic>? oldInventoryVersion =
          inventoryChanges['old_version'] as Map<String, dynamic>?;

      final int quantityAvailable = (earliestRestock.action == "update"
          ? (newInventoryVersion?['quantityAvailable'] as int? ?? 0)
          : (oldInventoryVersion?['quantityAvailable'] as int? ?? 0));

      final Map<String, dynamic>? newMetaVersion =
          inventoryMetaChanges['new_version'] as Map<String, dynamic>?;
      final Map<String, dynamic>? oldMetaVersion =
          inventoryMetaChanges['old_version'] as Map<String, dynamic>?;

      final double unitCost = (earliestRestock.action == "update"
          ? (newMetaVersion?['costPerUnit'] as double? ?? 0.0)
          : (oldMetaVersion?['costPerUnit'] as double? ?? 0.0));

      final int finalQuantity = quantityAvailable - quantitySold;
      final double amount = finalQuantity * unitCost;

      return {
        "start_date_quantity": finalQuantity,
        "start_date_unit_cost": unitCost,
        "amount": amount,
      };
    }

    return {
      "start_date_quantity": 0,
      "start_date_unit_cost": 0.0,
      "amount": 0.0,
    };
  }

  /// Calculates product quantity and value at end date
  static Map<String, dynamic> endDateProductAvailableQuantity(
    List<Sale> sales,
    Set<SaleItem> saleItems,
    List<ActionHistory> inventoryHistories,
    Inventory inventory,
    InventoryMetadata inventoryMetadata,
    DateTime endDate,
  ) {
    final futureInventories =
        inventoryHistories.where((x) => x.timestamp.isAfter(endDate)).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final closetRestock = futureInventories.isNotEmpty
        ? futureInventories.first
        : null;

    int lastQuantity = inventory.quantityAvailable;
    DateTime refDate = DateTime.now();

    if (closetRestock != null) {
      lastQuantity =
          closetRestock
              .changes['inventory']?['old_version']?['quantityAvailable'] ??
          lastQuantity;
      refDate = closetRestock.timestamp;
    }

    final salesAfterEnd = sales
        .where((x) => x.date.isAfter(endDate) && x.date.isBefore(refDate))
        .toList();

    final saleItemsAfterEnd = saleItems
        .where((x) => salesAfterEnd.map((y) => y.id).contains(x.saleId))
        .toList();

    final quantitySold = saleItemsAfterEnd.fold<int>(
      0,
      (sum, x) => sum + (x.quantity),
    );

    final double unitPrice = closetRestock != null
        ? (closetRestock
                  .changes['inventory_meta_data']?['new_version']?['costPerUnit'] ??
              0.0)
        : inventoryMetadata.costPerUnit;

    final int finalQuantity = lastQuantity - quantitySold;
    final double amount = finalQuantity * unitPrice;

    return {
      "end_date_quantity": finalQuantity,
      "end_date_unit_price": unitPrice,
      "amount": amount,
    };
  }

  /// Calculates total supply quantity and cost between two dates
  static Map<String, dynamic> periodSupplyQttValue(
    List<ActionHistory> inventoryHistories,
    DateTime startDate,
    DateTime endDate,
  ) {
    final supplies = inventoryHistories
        .where(
          (x) =>
              x.timestamp.isAfter(startDate) &&
              x.timestamp.isBefore(endDate) &&
              x.action == "update",
        )
        .toList();

    final int totalQuantity = supplies.fold<int>(0, (sum, n) {
      final int newQtt =
          n.changes['inventory']?['new_version']?['quantityAvailable'] ?? 0;
      final int oldQtt =
          n.changes['inventory']?['old_version']?['quantityAvailable'] ?? 0;
      return sum + (newQtt - oldQtt).abs();
    });

    final double totalCost = supplies.fold<double>(0.0, (sum, n) {
      final int newQtt =
          n.changes['inventory']?['new_version']?['quantityAvailable'] ?? 0;
      final int oldQtt =
          n.changes['inventory']?['old_version']?['quantityAvailable'] ?? 0;
      final int diffQtt = (newQtt - oldQtt).abs();
      final double unitCost =
          n.changes['inventory_meta_data']?['new_version']?['costPerUnit']
              ?.toDouble() ??
          0.0;
      return sum + diffQtt * unitCost;
    });

    return {"supply_quantity": totalQuantity, "supply_cost": totalCost};
  }

  /// Returns number of days between two dates (ignores time)
  static int daysBetween(DateTime from, DateTime to) {
    final normalizedFrom = DateTime(from.year, from.month, from.day);
    final normalizedTo = DateTime(to.year, to.month, to.day);
    return normalizedTo.difference(normalizedFrom).inDays;
  }
}

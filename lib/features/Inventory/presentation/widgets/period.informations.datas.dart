import 'package:super_manager/features/action_history/domain/entities/action.history.dart';
import 'package:super_manager/features/inventory_meta_data/domain/entities/inventory.meta.data.dart';

import '../../../sale/domain/entities/sale.dart';
import '../../../sale_item/domain/entities/sale.item.dart';
import '../../domain/entities/inventory.dart';

class PeriodInformationsDatas {
  static bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static salesQuantityDuringPeriod(
    List<Sale> sales,
    Set<SaleItem> saleItems,
    DateTime startDate,
    DateTime endDate,
  ) {
    var periodSale = sales
        .where((x) => x.date.isAfter(startDate) && x.date.isBefore(endDate))
        .toList()
        .where((x) => x.status == "Paid")
        .toList();
    var saleItemsPeriod = saleItems
        .where((x) => periodSale.map((y) => y.id).contains(x.saleId))
        .toList();
    final salePeriod = saleItemsPeriod.map((y) => y.quantity).toList();
    int saleQuantityPeriod = salePeriod.isNotEmpty
        ? salePeriod.reduce((a, b) => a + b)
        : 0;
    final salesRevenue = saleItemsPeriod
        .map((x) => x.quantity * x.unitPrice)
        .toList();
    double amount = salesRevenue.isNotEmpty
        ? salesRevenue.reduce((a, b) => a + b)
        : 0;
    return {
      "period_quantity_sold": saleQuantityPeriod,
      "period_quantity_revenue": amount,
    };
  }

  static startDateProductAvailableQuantity(
    List<Sale> sales,
    Set<SaleItem> saleItems,
    List<ActionHistory> myInventoryHistories,
    DateTime startDate,
  ) {
    final prevInventories = myInventoryHistories
        .where(
          (x) =>
              x.timestamp.isBefore(startDate) ||
              isSameDate(startDate, x.timestamp),
        )
        .toList();

    prevInventories.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final earliestRestock = prevInventories.lastOrNull;

    if (earliestRestock != null) {
      final salesAfterLastRestock = sales
          .where(
            (x) =>
                x.date.isAfter(earliestRestock.timestamp) &&
                x.date.isBefore(startDate),
          )
          .toList();

      final salesItemsALR = saleItems
          .where(
            (x) => salesAfterLastRestock
                .map((x) => x.id)
                .toList()
                .contains(x.saleId),
          )
          .toList();

      int quantitySale = salesItemsALR.isNotEmpty
          ? salesItemsALR
                .map((x) => x.quantity)
                .toList()
                .reduce((a, b) => a + b)
          : 0;

      final res = earliestRestock.action == "update"
          ? earliestRestock
                    .changes['inventory']!['new_version']['quantityAvailable'] -
                quantitySale
          : earliestRestock.changes['inventory']!['quantityAvailable'] -
                quantitySale;

      double unitPrice = earliestRestock.action == "update"
          ? earliestRestock
                .changes['inventory_meta_data']!['new_version']['costPerUnit']
          : earliestRestock.changes['inventory_meta_data']!['costPerUnit'];
      return {
        "start_date_quantity": res,
        "start_date_unit_cost": unitPrice,
        "amount": res * unitPrice,
      };
    }
    return {
      "start_date_quantity": 0,
      "start_date_unit_cost": 0.0,
      "amount": 0.0,
    };
  }

  static endDateProductAvailableQuantity(
    List<Sale> sales,
    Set<SaleItem> saleItems,
    List<ActionHistory> myInventoryHistories,
    Inventory inventory,
    InventoryMetadata inventoryMetadata,
    DateTime endDate,
  ) {
    final nextInventories = myInventoryHistories
        .where((x) => x.timestamp.isAfter(endDate))
        .toList();
    nextInventories.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final closetRestock = nextInventories.firstOrNull;
    int quantityLastRestock = inventory.quantityAvailable;
    DateTime refDate = DateTime.now();
    if (closetRestock != null) {
      refDate = closetRestock.timestamp;
      quantityLastRestock = closetRestock
          .changes['inventory']!['old_version']['quantityAvailable'];
    }
    final salesAfterLastRestock = sales
        .where((x) => x.date.isAfter(endDate) && x.date.isBefore(refDate))
        .toList();
    final salesItemsALR = saleItems
        .where(
          (x) => salesAfterLastRestock
              .map((x) => x.id)
              .toList()
              .contains(x.saleId),
        )
        .toList();
    int quantitySale = salesItemsALR.isNotEmpty
        ? salesItemsALR.map((x) => x.quantity).toList().reduce((a, b) => a + b)
        : 0;
    final result = quantityLastRestock - quantitySale;
    double unitPrice = closetRestock != null
        ? closetRestock
              .changes['inventory_meta_data']!['new_version']['costPerUnit']
        : inventoryMetadata.costPerUnit;
    return {
      "end_date_quantity": result,
      "end_date_unit_price": unitPrice,
      "amount": result * unitPrice,
    };
  }

  static periodSupplyQttValue(
    List<ActionHistory> myInventoryHistories,
    DateTime startDate,
    DateTime endDate,
  ) {
    final supply = myInventoryHistories.where(
      (x) => x.timestamp.isBefore(endDate) && x.timestamp.isAfter(startDate),
    );
    final supplies = supply.where((x) => x.action == "update").toList();
    if (supplies.isNotEmpty) {
      int qtt = 0;
      double price = 0;
      for (var n in supplies) {
        int nV = n.changes['inventory']!['new_version']['quantityAvailable'];
        int oV = n.changes['inventory']!['old_version']['quantityAvailable'];
        int diffV = (nV - oV).abs();
        qtt += diffV;
        final p =
            diffV *
            n.changes['inventory_meta_data']!['new_version']['costPerUnit'];
        price += p;
      }
      return {"supply_quantity": qtt, "supply_cost": price};
    } else {
      return {"supply_quantity": 0, "supply_cost": 0.0};
    }
  }

  static int daysBetween(DateTime from, DateTime to) {
    // Normalize the dates to ignore time components
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);

    return to.difference(from).inDays;
  }
}

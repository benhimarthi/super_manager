import 'package:super_manager/core/apllication_method/inventory.kpi.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/period.informations.datas.dart';
import 'package:super_manager/features/sale/domain/entities/sale.dart';
import 'package:super_manager/features/sale_item/domain/entities/sale.item.dart';
import 'package:super_manager/features/action_history/domain/entities/action.history.dart';

import '../../../../inventory_meta_data/domain/entities/inventory.meta.data.dart';

class InventoryKpiService {
  final Inventory inventory;
  final InventoryMetadata inventoryMetadata;
  final List<ActionHistory> histories;
  final List<Sale> sales;
  final Set<SaleItem> saleItems;

  InventoryKpiService({
    required this.inventory,
    required this.inventoryMetadata,
    required this.histories,
    required this.sales,
    required this.saleItems,
  });

  double averageInventory(DateTime start, DateTime end) {
    return InventoryKPI.averageInventory(
      PeriodInformationsDatas.startDateProductAvailableQuantity(
        sales,
        saleItems,
        histories,
        start,
      )['amount'],
      PeriodInformationsDatas.endDateProductAvailableQuantity(
        sales,
        saleItems,
        histories,
        inventory,
        inventoryMetadata,
        end,
      )['amount'],
    );
  }

  double COGS(DateTime start, DateTime end) {
    return PeriodInformationsDatas.startDateProductAvailableQuantity(
          sales,
          saleItems,
          histories,
          start,
        )['amount'] +
        PeriodInformationsDatas.periodSupplyQttValue(
          histories,
          start,
          end,
        )['supply_cost'] -
        PeriodInformationsDatas.endDateProductAvailableQuantity(
          sales,
          saleItems,
          histories,
          inventory,
          inventoryMetadata,
          end,
        )['amount'];
  }

  double inventoryTurnOver(DateTime start, DateTime end) =>
      InventoryKPI.inventoryTurnover(
        COGS(start, end),
        averageInventory(start, end),
      );

  double grossMarginReturnOnInvestment(DateTime start, DateTime end) =>
      InventoryKPI.gmroi(
        PeriodInformationsDatas.salesQuantityDuringPeriod(
          sales,
          saleItems,
          start,
          end,
        )['period_quantity_revenue'],
        COGS(start, end),
        averageInventory(start, end),
      );

  double stockToSalesRatio(DateTime start, DateTime end) =>
      InventoryKPI.stockToSalesRatio(
        averageInventory(start, end),
        PeriodInformationsDatas.salesQuantityDuringPeriod(
          sales,
          saleItems,
          start,
          end,
        )['period_quantity_revenue'],
      );

  double daysOfInventoryOnHand(DateTime start, DateTime end) =>
      InventoryKPI.daysOfInventoryOnHand(
        averageInventory(start, end),
        COGS(start, end),
        PeriodInformationsDatas.daysBetween(start, end),
      );

  double sellThroughRate(DateTime start, DateTime end) =>
      InventoryKPI.sellThroughRate(
        PeriodInformationsDatas.salesQuantityDuringPeriod(
          sales,
          saleItems,
          start,
          end,
        )['period_quantity_sold'],
        PeriodInformationsDatas.periodSupplyQttValue(
              histories,
              start,
              end,
            )['supply_quantity'] +
            PeriodInformationsDatas.startDateProductAvailableQuantity(
              sales,
              saleItems,
              histories,
              start,
            )['start_date_quantity'],
      );
}

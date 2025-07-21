class InventoryKPI {
  // Average Inventory Level
  static double averageInventory(double beginning, double ending) =>
      (beginning + ending) / 2;

  // Inventory Turnover Rate
  static double inventoryTurnover(double cogs, double avgInventory) =>
      cogs / avgInventory;

  // Order Lead Time (in days)
  static int orderLeadTime(DateTime orderDate, DateTime deliveryDate) =>
      deliveryDate.difference(orderDate).inDays;

  // Gross Margin Return on Investment (GMROI)
  static double gmroi(
    double salesRevenue,
    double cogs,
    double avgInventoryCost,
  ) => (salesRevenue - cogs) / avgInventoryCost;

  // Stockout Rate (as percentage)
  static double stockoutRate(int numStockouts, int totalOrders) =>
      (numStockouts / totalOrders) * 100;

  // Lost Sales Ratio (as percentage)
  static double lostSalesRatio(int daysOutOfStock, int totalSalesDays) =>
      (daysOutOfStock / totalSalesDays) * 100;

  // Perfect Order Rate (as percentage)
  static double perfectOrderRate(int perfectOrders, int totalOrders) =>
      (perfectOrders / totalOrders) * 100;

  // Inventory Shrinkage Rate (as percentage)
  static double inventoryShrinkage(double recordedInv, double countedInv) =>
      ((recordedInv - countedInv) / recordedInv) * 100;

  // Average Days to Sell Inventory
  static double avgDaysToSell(
    double avgInventory,
    double cogs,
    int daysInPeriod,
  ) => (avgInventory / cogs) * daysInPeriod;
}

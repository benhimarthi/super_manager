class InventoryMetaDataMethods {
  double calculateTotalStockValue(double costPerUnit, int quantity) {
    return costPerUnit * quantity;
  }

  double markupPercentage(double sellingPrice, double costPrice) {
    return ((sellingPrice - costPrice) / costPrice) * 100;
  }

  double costPerUnit(double totalStockValue, int productNb) {
    return totalStockValue / productNb;
  }

  double averageDailySales(double totalSaleInPerio, int dayNbInPeriod) {
    return totalSaleInPerio / dayNbInPeriod;
  }

  double stockTurnoverRate(double costOfProductsSale, double averageInventory) {
    return costOfProductsSale / averageInventory;
  }

  double averageInventory(
    double inventoryAtTheBeginning,
    double inventoryAtEnd,
  ) {
    return (inventoryAtTheBeginning + inventoryAtEnd) / 2;
  }

  double costOfGoodsSold(
    double beginningInv,
    double purchases,
    double endingInv,
  ) {
    return beginningInv + purchases + endingInv;
  }
}

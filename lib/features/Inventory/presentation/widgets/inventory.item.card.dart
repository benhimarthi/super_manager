import 'package:flutter/material.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';

import '../../../inventory_meta_data/domain/entities/inventory.meta.data.dart';
import '../../domain/entities/inventory.dart';

class InventoryItemCard extends StatelessWidget {
  final Inventory inventory;
  final Product? product;
  final InventoryMetadata? metadata;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InventoryItemCard({
    Key? key,
    required this.inventory,
    this.product,
    this.metadata,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  Color get stockStatusColor {
    if (inventory.isBlocked) return Colors.grey;
    if (inventory.isOutOfStock) return Colors.red;
    if (inventory.isLowStock) return Colors.orange;
    return Colors.green;
  }

  String get stockStatusText {
    if (inventory.isBlocked) return 'Blocked';
    if (inventory.isOutOfStock) return 'Out of Stock';
    if (inventory.isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inventory basic info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Product ID: ${product != null ? product!.name : "your product"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  /*Expanded(
                    child: Text(
                      'Codebare: ${product != null ? product!.barcode : "your product"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),*/
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildQuantityInfo('Available', inventory.quantityAvailable),
                  _buildQuantityInfo('Reserved', inventory.quantityReserved),
                  _buildQuantityInfo('Sold', inventory.quantitySold),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Stock Status: $stockStatusText',
                style: TextStyle(
                  color: stockStatusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Metadata info (conditionally shown)
              if (metadata != null) ...[
                const Divider(),
                const Text(
                  'Metadata',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cost Per Unit: \$${metadata!.costPerUnit.toStringAsFixed(2)}',
                ),
                Text(
                  'Total Stock Value: \$${metadata!.totalStockValue.toStringAsFixed(2)}',
                ),
                Text(
                  'Markup: ${metadata!.markupPercentage.toStringAsFixed(2)}%',
                ),
                Text(
                  'Avg Daily Sales: ${metadata!.averageDailySales.toStringAsFixed(2)}',
                ),
                Text(
                  'Stock Turnover Rate: ${metadata!.stockTurnoverRate.toStringAsFixed(2)}',
                ),
                Text('Lead Time (Days): ${metadata!.leadTimeInDays}'),
                Text(
                  'Demand Forecast: ${metadata!.demandForecast.toStringAsFixed(2)}',
                ),
                Text(
                  'Seasonality Factor: ${metadata!.seasonalityFactor.toStringAsFixed(2)}',
                ),
              ] else
                const Text(
                  'No metadata available',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),

              // Actions
              if (onEdit != null || onDelete != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                        ),
                      if (onDelete != null)
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityInfo(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}

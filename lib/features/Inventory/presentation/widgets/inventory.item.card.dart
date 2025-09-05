import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.item.card.date.selector.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.relevant.numbers.view.dart';
import 'package:super_manager/features/action_history/domain/entities/action.history.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../inventory_meta_data/domain/entities/inventory.meta.data.dart';
import '../../domain/entities/inventory.dart';

class InventoryItemCard extends StatefulWidget {
  final List<Inventory> myInventories;
  final List<ActionHistory> myInventoryHistory;
  final Inventory inventory;
  final Product? product;
  final InventoryMetadata? metadata;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isInfoDisplayer;

  const InventoryItemCard({
    super.key,
    required this.myInventories,
    required this.inventory,
    required this.myInventoryHistory,
    required this.isInfoDisplayer,
    this.product,
    this.metadata,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<InventoryItemCard> createState() => _InventoryItemCardState();
}

class _InventoryItemCardState extends State<InventoryItemCard> {
  @override
  void initState() {
    super.initState();
    context.read<WidgetManipulatorCubit>().emitRandomElement({
      "id": "activity_numbers",
      "inv_id": widget.inventory.id,
      "datas": {
        "available_quantity": widget.inventory.quantityAvailable,
        "reserved_quantity": widget.inventory.quantityReserved,
        "sold_quantity": widget.inventory.quantitySold,
      },
    });
  }

  Color get stockStatusColor {
    if (widget.inventory.isBlocked) return Colors.grey;
    if (widget.inventory.isOutOfStock) return Colors.red;
    if (widget.inventory.isLowStock) return Colors.orange;
    return Colors.green;
  }

  String get stockStatusText {
    if (widget.inventory.isBlocked) return 'Blocked';
    if (widget.inventory.isOutOfStock) return 'Out of Stock';
    if (widget.inventory.isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: const Color.fromARGB(255, 27, 29, 31),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product!.name,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              InventoryItemCardDateSelector(
                myHistories: widget.myInventoryHistory,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildQuantityInfo(
                    'Available',
                    widget.inventory.quantityAvailable,
                    context,
                  ),
                  _buildQuantityInfo(
                    'Reserved',
                    widget.inventory.quantityReserved,
                    context,
                  ),
                  _buildQuantityInfo(
                    'Sold',
                    widget.inventory.quantitySold,
                    context,
                  ),
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
              if (widget.metadata != null) ...[
                const Divider(),
                InventoryRelevantNumbersView(
                  inventory: widget.inventory,
                  inventoryMetadata: widget.metadata!,
                  inventoryVersions: widget.myInventories,
                  myInventoryHistories: widget.myInventoryHistory,
                  infoDisplayer: widget.isInfoDisplayer,
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
              if (widget.onEdit != null || widget.onDelete != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.onEdit != null)
                        TextButton.icon(
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                        ),
                      if (widget.onDelete != null)
                        TextButton.icon(
                          onPressed: widget.onDelete,
                          icon: const Icon(
                            Icons.delete,
                            size: 18,
                            color: Color.fromARGB(255, 244, 54, 54),
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

  Widget _buildQuantityInfo(String label, int value, context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.available.product.list.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';
import 'package:super_manager/features/product/presentation/cubit/product.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import '../../domain/entities/inventory.dart';

class InventoryFormData extends StatefulWidget {
  final Inventory? inventory;
  const InventoryFormData({super.key, this.inventory});

  @override
  State<InventoryFormData> createState() => _InventoryFormDataState();
}

class _InventoryFormDataState extends State<InventoryFormData> {
  final _formKey = GlobalKey<FormState>();

  // Inventory controllers
  late TextEditingController _productIdController;
  late TextEditingController _warehouseIdController;
  late TextEditingController _quantityAvailableController;
  late TextEditingController _quantityReservedController;
  late TextEditingController _quantitySoldController;
  late TextEditingController _reorderLevelController;
  late TextEditingController _minimumStockController;
  late TextEditingController _maximumStockController;
  late bool _isOutOfStock;
  late bool _isLowStock;
  late bool _isBlocked;
  late DateTime _lastRestockDate;

  @override
  void initState() {
    super.initState();
    final inv = widget.inventory;
    // Inventory init
    _productIdController = TextEditingController(text: inv?.productId ?? '');
    _warehouseIdController = TextEditingController(
      text: inv?.warehouseId ?? '',
    );
    _quantityAvailableController = TextEditingController(
      text: inv?.quantityAvailable.toString() ?? '0',
    );
    _quantityReservedController = TextEditingController(
      text: inv?.quantityReserved.toString() ?? '0',
    );
    _quantitySoldController = TextEditingController(
      text: inv?.quantitySold.toString() ?? '0',
    );
    _reorderLevelController = TextEditingController(
      text: inv?.reorderLevel.toString() ?? '0',
    );
    _minimumStockController = TextEditingController(
      text: inv?.minimumStock.toString() ?? '0',
    );
    _maximumStockController = TextEditingController(
      text: inv?.maximumStock.toString() ?? '0',
    );
    _isOutOfStock = inv?.isOutOfStock ?? false;
    _isLowStock = inv?.isLowStock ?? false;
    _isBlocked = inv?.isBlocked ?? false;
    _lastRestockDate = inv?.lastRestockDate ?? DateTime.now();
  }

  @override
  void dispose() {
    super.dispose();
    // Inventory controllers
    _productIdController.dispose();
    _warehouseIdController.dispose();
    _quantityAvailableController.dispose();
    _quantityReservedController.dispose();
    _quantitySoldController.dispose();
    _reorderLevelController.dispose();
    _minimumStockController.dispose();
    _maximumStockController.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final inventory = Inventory(
        id: widget.inventory?.id ?? UniqueKey().toString(),
        productId: _productIdController.text,
        warehouseId: _warehouseIdController.text,
        quantityAvailable: int.parse(_quantityAvailableController.text),
        quantityReserved: int.parse(_quantityReservedController.text),
        quantitySold: int.parse(_quantitySoldController.text),
        reorderLevel: int.parse(_reorderLevelController.text),
        minimumStock: int.parse(_minimumStockController.text),
        maximumStock: int.parse(_maximumStockController.text),
        isOutOfStock: _isOutOfStock,
        isLowStock: _isLowStock,
        isBlocked: _isBlocked,
        lastRestockDate: _lastRestockDate,
        createdAt: widget.inventory?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> _selectRestockDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastRestockDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _lastRestockDate) {
      setState(() {
        _lastRestockDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.inventory != null;
    return AlertDialog(
      title: AppBar(
        title: Text(
          isEditing ? 'Edit Inventory' : 'Add Inventory',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
      content: SingleChildScrollView(
        //padding: const EdgeInsets.all(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
                listener: (context, state) {
                  if (state is EmitRandomElementSuccessfully) {
                    try {
                      var productId = (state.element as String);
                      _productIdController.text = productId;
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                builder: (context, state) {
                  return InventoryAvailableProductList();
                },
              ),
              Visibility(
                visible: false,
                child: TextFormField(
                  controller: _productIdController,
                  decoration: const InputDecoration(labelText: 'Product ID'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
              Visibility(
                visible: false,
                child: TextFormField(
                  controller: _warehouseIdController,
                  decoration: const InputDecoration(labelText: 'Warehouse ID'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _quantityAvailableController,
                decoration: const InputDecoration(
                  labelText: 'Quantity Available',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _quantityReservedController,
                decoration: const InputDecoration(
                  labelText: 'Quantity Reserved',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
              /*SizedBox(height: 15),
              TextFormField(
                controller: _quantitySoldController,
                decoration: const InputDecoration(labelText: 'Quantity Sold'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),*/
              SizedBox(height: 15),
              TextFormField(
                controller: _reorderLevelController,
                decoration: const InputDecoration(labelText: 'Reorder Level'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _minimumStockController,
                decoration: const InputDecoration(labelText: 'Minimum Stock'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _maximumStockController,
                decoration: const InputDecoration(labelText: 'Maximum Stock'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),

              /*SwitchListTile(
                title: const Text('Out of Stock'),
                value: _isOutOfStock,
                onChanged: (val) => setState(() => _isOutOfStock = val),
              ),
              SwitchListTile(
                title: const Text('Low Stock'),
                value: _isLowStock,
                onChanged: (val) => setState(() => _isLowStock = val),
              ),
              SwitchListTile(
                title: const Text('Blocked'),
                value: _isBlocked,
                onChanged: (val) => setState(() => _isBlocked = val),
              ),*/
              ListTile(
                title: const Text('Last Restock Date'),
                subtitle: Text('${_lastRestockDate.toLocal()}'.split(' ')[0]),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectRestockDate(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

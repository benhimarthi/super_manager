import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/session/session.manager.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.available.product.list.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.meta.data.form.dart';
import 'package:super_manager/features/inventory_meta_data/domain/entities/inventory.meta.data.dart';
import 'package:super_manager/features/synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import 'package:uuid/uuid.dart';
import '../../../synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.state.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import '../../domain/entities/inventory.dart';

class InventoryFormData extends StatefulWidget {
  final List<Inventory> myInventories;
  final Inventory? inventory;
  final bool isBuilding;
  const InventoryFormData({
    super.key,
    required this.myInventories,
    required this.isBuilding,
    this.inventory,
  });

  @override
  State<InventoryFormData> createState() => _InventoryFormDataState();
}

class _InventoryFormDataState extends State<InventoryFormData> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityAvailableController;
  late TextEditingController _quantityReservedController;
  late TextEditingController _quantitySoldController;
  late TextEditingController _reorderLevelController;
  late TextEditingController _minimumStockController;
  late TextEditingController _maximumStockController;
  late bool _isOutOfStock;
  late bool _isLowStock;
  late bool _isBlocked;
  late bool _displayWarning;
  late bool _createCopy;
  late DateTime _lastRestockDate;
  late int page;
  late String inventoryId;
  late String productId;
  late InventoryMetadata? metadata;

  @override
  void initState() {
    super.initState();
    _createCopy = false;
    metadata = null;
    productId = widget.inventory != null ? widget.inventory!.productId : "";
    _displayWarning = false;
    final inv = widget.inventory;
    page = 0;
    inventoryId = inv?.id ?? Uuid().v4();

    // Inventory init
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
    if (widget.inventory != null) {
      context.read<InventoryMetadataCubit>().loadMetadata();
    }
  }

  @override
  void dispose() {
    _quantityAvailableController.dispose();
    _quantityReservedController.dispose();
    _quantitySoldController.dispose();
    _reorderLevelController.dispose();
    _minimumStockController.dispose();
    _maximumStockController.dispose();
    super.dispose();
  }

  _save() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.inventory != null && !widget.isBuilding) {
        final inv = widget.inventory;
        _createCopy =
            int.parse(_quantityAvailableController.text) !=
                inv!.quantityAvailable ||
            int.parse(_quantityReservedController.text) !=
                inv.quantityReserved ||
            int.parse(_quantitySoldController.text) != inv.quantitySold;
      }
      final inventory = Inventory(
        id: inventoryId,
        productId: productId,
        userUid: SessionManager.getUserSession()!.id,
        warehouseId: "",
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
      return inventory;
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocConsumer<InventoryMetadataCubit, InventoryMetadataState>(
            listener: (context, state) {
              if (state is InventoryMetadataManagerLoaded) {
                var metaData = state.metadataList
                    .where((x) => x.inventoryId == inventoryId)
                    .firstOrNull;
                if (metaData != null) {
                  metadata = metaData;
                }
              }
            },
            builder: (context, state) {
              return Container();
            },
          ),
          Text(
            isEditing ? 'Edit Inventory' : 'Add Inventory',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              if (productId.isEmpty) {
                setState(() {
                  _displayWarning = true;
                });
                return;
              }
              var prod = _save();
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) {
                  return InventoryMetaDataForm(
                    inventory: prod,
                    oldVersion: widget.inventory,
                    isBuilding: widget.isBuilding,
                    inventoryMetadata: metadata,
                    duplicate: _createCopy,
                  );
                },
              );
            },
            child: Text(
              "Next",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
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
                      setState(() {
                        //print(productId);
                        this.productId = productId;
                        _displayWarning = false;
                      });
                    } catch (e) {}
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      Visibility(
                        visible: _displayWarning,
                        child: Text(
                          "You must select a product.",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 100,
                            decoration: _displayWarning
                                ? BoxDecoration(
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  )
                                : BoxDecoration(),
                          ),
                          InventoryAvailableProductList(
                            selectedItem: widget.inventory != null
                                ? widget.inventory!.productId
                                : "",
                            existionInventories: widget.myInventories,
                          ),
                        ],
                      ),
                    ],
                  );
                },
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
              Transform.scale(
                scale: .7,
                child: SwitchListTile(
                  title: const Text('Blocked'),
                  value: _isBlocked,
                  onChanged: (val) => setState(() => _isBlocked = val),
                ),
              ),
              ListTile(
                title: Text(
                  'Last Restock Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
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

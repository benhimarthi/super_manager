import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.form.data.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.meta.data.form.dart';

import '../../../inventory_meta_data/domain/entities/inventory.meta.data.dart';
import '../../../synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.cubit.dart';
import '../../domain/entities/inventory.dart';
import '../cubit/inventory.cubit.dart';

// Assume Inventory and InventoryMetadata entities are imported

class InventoryDetailScreen extends StatefulWidget {
  final Inventory? inventory;
  final InventoryMetadata? metadata;

  const InventoryDetailScreen({Key? key, this.inventory, this.metadata})
    : super(key: key);

  @override
  _InventoryDetailScreenState createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late Inventory? inventory;
  // Metadata controllers
  late TextEditingController _costPerUnitController;
  late TextEditingController _totalStockValueController;
  late TextEditingController _markupPercentageController;
  late TextEditingController _averageDailySalesController;
  late TextEditingController _stockTurnoverRateController;
  late TextEditingController _leadTimeInDaysController;
  late TextEditingController _demandForecastController;
  late TextEditingController _seasonalityFactorController;
  late TextEditingController _inventorySourceController;
  late TextEditingController _createdByController;
  late TextEditingController _updatedByController;

  @override
  void initState() {
    super.initState();

    final inv = widget.inventory;
    inventory = inv;
    final meta = widget.metadata;

    // Metadata init
    _costPerUnitController = TextEditingController(
      text: meta?.costPerUnit.toString() ?? '0.0',
    );
    _totalStockValueController = TextEditingController(
      text: meta?.totalStockValue.toString() ?? '0.0',
    );
    _markupPercentageController = TextEditingController(
      text: meta?.markupPercentage.toString() ?? '0.0',
    );
    _averageDailySalesController = TextEditingController(
      text: meta?.averageDailySales.toString() ?? '0.0',
    );
    _stockTurnoverRateController = TextEditingController(
      text: meta?.stockTurnoverRate.toString() ?? '0.0',
    );
    _leadTimeInDaysController = TextEditingController(
      text: meta?.leadTimeInDays.toString() ?? '0',
    );
    _demandForecastController = TextEditingController(
      text: meta?.demandForecast.toString() ?? '0.0',
    );
    _seasonalityFactorController = TextEditingController(
      text: meta?.seasonalityFactor.toString() ?? '0.0',
    );
    _inventorySourceController = TextEditingController(
      text: meta?.inventorySource ?? '',
    );
    _createdByController = TextEditingController(text: meta?.createdBy ?? '');
    _updatedByController = TextEditingController(text: meta?.updatedBy ?? '');
  }

  @override
  void dispose() {
    // Metadata controllers
    _costPerUnitController.dispose();
    _totalStockValueController.dispose();
    _markupPercentageController.dispose();
    _averageDailySalesController.dispose();
    _stockTurnoverRateController.dispose();
    _leadTimeInDaysController.dispose();
    _demandForecastController.dispose();
    _seasonalityFactorController.dispose();
    _inventorySourceController.dispose();
    _createdByController.dispose();
    _updatedByController.dispose();

    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final metadata = InventoryMetadata(
        id: widget.metadata?.id ?? UniqueKey().toString(),
        inventoryId: "", //inventory.id,
        costPerUnit: double.parse(_costPerUnitController.text),
        totalStockValue: double.parse(_totalStockValueController.text),
        markupPercentage: double.parse(_markupPercentageController.text),
        averageDailySales: double.parse(_averageDailySalesController.text),
        stockTurnoverRate: double.parse(_stockTurnoverRateController.text),
        leadTimeInDays: int.parse(_leadTimeInDaysController.text),
        demandForecast: double.parse(_demandForecastController.text),
        seasonalityFactor: double.parse(_seasonalityFactorController.text),
        inventorySource: _inventorySourceController.text,
        createdBy: _createdByController.text,
        updatedBy: _updatedByController.text,
      );

      final inventoryCubit = context.read<InventoryCubit>();
      final metadataCubit = context.read<InventoryMetadataCubit>();

      if (widget.inventory == null) {
        inventoryCubit.addInventory(inventory!);
        metadataCubit.addMetadata(metadata);
      } else {
        inventoryCubit.updateInventory(inventory!);
        metadataCubit.updateMetadata(metadata);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.inventory != null;

    return Scaffold(
      floatingActionButton: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return InventoryMetaDataForm(inventory: inventory);
            },
          );
        },
        child: CircleAvatar(),
      ),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Inventory' : 'Add Inventory'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(2),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InventoryFormData(),
              InventoryMetaDataForm(inventory: null),
              const Divider(height: 40),
              const Text(
                'Inventory Metadata',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              TextFormField(
                controller: _costPerUnitController,
                decoration: const InputDecoration(labelText: 'Cost Per Unit'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
              TextFormField(
                controller: _totalStockValueController,
                decoration: const InputDecoration(
                  labelText: 'Total Stock Value',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
              TextFormField(
                controller: _markupPercentageController,
                decoration: const InputDecoration(
                  labelText: 'Markup Percentage',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
              TextFormField(
                controller: _averageDailySalesController,
                decoration: const InputDecoration(
                  labelText: 'Average Daily Sales',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
              TextFormField(
                controller: _stockTurnoverRateController,
                decoration: const InputDecoration(
                  labelText: 'Stock Turnover Rate',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
              TextFormField(
                controller: _leadTimeInDaysController,
                decoration: const InputDecoration(
                  labelText: 'Lead Time (Days)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
              TextFormField(
                controller: _demandForecastController,
                decoration: const InputDecoration(labelText: 'Demand Forecast'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
              TextFormField(
                controller: _seasonalityFactorController,
                decoration: const InputDecoration(
                  labelText: 'Seasonality Factor',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Enter valid number'
                    : null,
              ),
              TextFormField(
                controller: _inventorySourceController,
                decoration: const InputDecoration(
                  labelText: 'Inventory Source',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _createdByController,
                decoration: const InputDecoration(labelText: 'Created By'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _updatedByController,
                decoration: const InputDecoration(labelText: 'Updated By'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? 'Update' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

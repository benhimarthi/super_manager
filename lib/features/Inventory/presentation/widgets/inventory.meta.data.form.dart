import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/apllication_method/inventory.meta.data.methods.dart';
import 'package:super_manager/core/session/session.manager.dart';
import 'package:super_manager/features/Inventory/data/models/inventory.model.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/Inventory/presentation/cubit/inventory.cubit.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.form.data.dart';
import 'package:super_manager/features/inventory_meta_data/data/models/inventory.meta.data.model.dart';
import 'package:super_manager/features/inventory_meta_data/domain/entities/inventory.meta.data.dart';
import 'package:super_manager/features/product/data/models/product.model.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';
import 'package:super_manager/features/product/presentation/cubit/product.cubit.dart';
import 'package:super_manager/features/product_pricing/data/models/product.pricing.model.dart';
import 'package:super_manager/features/product_pricing/domain/entities/product.pricing.dart';
import 'package:super_manager/features/product_pricing/presentation/cubit/product.pricing.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.cubit.dart';

import '../../../product/presentation/cubit/product.state.dart';
import '../../../product_pricing/presentation/cubit/product.pricing.state.dart';

class InventoryMetaDataForm extends StatefulWidget {
  final Inventory? inventory;
  final InventoryMetadata? inventoryMetadata;
  final bool isBuilding;
  const InventoryMetaDataForm({
    super.key,
    required this.inventory,
    this.inventoryMetadata,
    required this.isBuilding,
  });

  @override
  State<InventoryMetaDataForm> createState() => _InventoryMetaDataFormState();
}

class _InventoryMetaDataFormState extends State<InventoryMetaDataForm> {
  late Product inventoryProduct;
  late ProductPricing productPricing;
  late Inventory inv;
  late InventoryMetaDataMethods cl;
  late double costPerUnity = 0;
  late double totalStockValue = 1500;
  late TextEditingController _totalStockValue;
  late TextEditingController _leadTime;
  late bool isEditing;
  late String metaDataUid;
  final _formKey = GlobalKey<FormState>();

  late String markupPercentage;
  late String averageDailySales;
  late double stockTurnoverRate;
  late double leadTimeInDays;
  late double demandForecast;
  late double seasonalityFactor;
  late double inventorySource;

  @override
  void initState() {
    super.initState();
    markupPercentage = "0";
    if (widget.inventoryMetadata != null) {
      isEditing = true;
    } else {
      isEditing = false;
    }
    _totalStockValue = TextEditingController(
      text: widget.inventoryMetadata != null
          ? widget.inventoryMetadata!.totalStockValue.toString()
          : "0.0",
    );
    _leadTime = TextEditingController(
      text: widget.inventoryMetadata != null
          ? widget.inventoryMetadata!.leadTimeInDays.toString()
          : "0",
    );
    metaDataUid = widget.inventoryMetadata?.id ?? UniqueKey().toString();
    cl = InventoryMetaDataMethods();
    inv = (widget.inventory ?? InventoryModel.empty());
    inventoryProduct = ProductModel.empty();
    productPricing = ProductPricingModel.empty();
    costPerUnity = cl.costPerUnit(
      totalStockValue,
      inv.quantityAvailable + inv.quantityReserved,
    );
    if (widget.inventory != null) {
      context.read<ProductCubit>().getProductById(widget.inventory!.productId);
    }
  }

  _save() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.isBuilding) {
        final metadata = InventoryMetadata(
          id: metaDataUid,
          inventoryId: inv.id,
          costPerUnit: costPerUnity,
          totalStockValue: double.parse(_totalStockValue.text),
          markupPercentage: 0,
          averageDailySales: 0,
          stockTurnoverRate: 0,
          leadTimeInDays: int.parse(_leadTime.text),
          demandForecast: 0,
          seasonalityFactor: 0,
          inventorySource: "",
          createdBy: SessionManager.getUserSession()!.id,
          updatedBy: SessionManager.getUserSession()!.id,
        );
        context.read<InventoryCubit>().addInventory(widget.inventory!);
        context.read<InventoryMetadataCubit>().addMetadata(metadata);
      } else {
        var metadata = (widget.inventory as InventoryMetadataModel).copyWith(
          totalStockValue: double.parse(_totalStockValue.text),
          leadTimeInDays: int.parse(_leadTime.text),
          updatedBy: SessionManager.getUserSession()!.id,
        );
        context.read<InventoryCubit>().updateInventory(widget.inventory!);
        context.read<InventoryMetadataCubit>().updateMetadata(metadata);
      }
    }
  }

  @override
  void dispose() {
    _totalStockValue.dispose();
    _leadTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Inventory metaData',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) {
                  return InventoryFormData(
                    inventory: widget.inventory,
                    isBuilding: true,
                  );
                },
              );
            },
            child: Text(
              "Prev",
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _totalStockValue,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: Text("Total stock value"),
                      suffixIcon: Icon(
                        Icons.help,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "This filed can not be null";
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _leadTime,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: Text("Lead Time"),
                      suffixIcon: Icon(
                        Icons.help,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            /*BlocConsumer<ProductCubit, ProductState>(
              listener: (context, state) {
                if (state is GetProductByIdSuccessfully) {
                  inventoryProduct = state.product;
                  context.read<ProductPricingCubit>().loadPricing();
                }
              },
              builder: (context, state) {
                return Row(
                  children: [
                    inventoryMetaDataItem(
                      "Cost per unit",
                      costPerUnity.toStringAsFixed(1),
                      "DH",
                    ),
                    SizedBox(width: 10),
                    inventoryMetaDataItem("Stock turnover rate", "0.45", ""),
                  ],
                );
              },
            ),
            BlocConsumer<ProductPricingCubit, ProductPricingState>(
              listener: (context, state) {
                if (state is ProductPricingManagerLoaded) {
                  var currentP = state.pricingList
                      .where((x) => x.productId == widget.inventory!.productId)
                      .firstOrNull;
                  if (currentP != null) {
                    productPricing = currentP;
                    markupPercentage = cl
                        .markupPercentage(productPricing.amount, costPerUnity)
                        .toStringAsFixed(1);
                  }
                }
              },
              builder: (context, state) {
                return Container();
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                inventoryMetaDataItem(
                  "Markup Percentage",
                  markupPercentage,
                  "%",
                ),
                SizedBox(width: 10),
                inventoryMetaDataItem("Avarage Daily Sales", "0.6", "DH"),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                inventoryMetaDataItem("Demand forecast", "0.45", ""),
                SizedBox(width: 10),
                inventoryMetaDataItem("Seasonality Factor", "0.6", "h"),
              ],
            ),
            SizedBox(height: 10),*/
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  inventoryMetaDataItem(String title, String value, String unity) {
    return Container(
      width: 135,
      decoration: BoxDecoration(
        color: Color.fromARGB(102, 159, 122, 234),
        borderRadius: BorderRadius.circular(5),
        /*BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),*/
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 3),
                    CircleAvatar(
                      radius: 10,
                      child: Center(child: Icon(Icons.help, size: 18)),
                    ),
                  ],
                ),
              ),
              Container(
                width: 130,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: " $unity",
                          style: TextStyle(
                            color: Colors.lightGreen,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

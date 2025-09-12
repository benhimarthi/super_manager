import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/inventory_meta_data/domain/entities/inventory.meta.data.dart';
import 'package:super_manager/features/product/presentation/cubit/product.cubit.dart';
import 'package:super_manager/features/product/presentation/cubit/product.state.dart';
import 'package:super_manager/features/product/presentation/widgets/product.card.item.carousel.dart';
import 'package:super_manager/features/product_pricing/presentation/cubit/product.pricing.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/widgets/product.card.pricing.dart';
import '../../../product_pricing/domain/entities/product.pricing.dart';
import '../../../product_pricing/presentation/cubit/product.pricing.state.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import 'register.sale.form.dart';

class SaleItem extends StatefulWidget {
  final Inventory inventory;
  final Product product;
  final InventoryMetadata inventoryMetadata;
  const SaleItem({
    super.key,
    required this.inventory,
    required this.product,
    required this.inventoryMetadata,
  });

  @override
  State<SaleItem> createState() => _SaleItemState();
}

class _SaleItemState extends State<SaleItem> {
  late ProductPricing? productPricing;
  late int currentPos = 3;
  late bool saleProduct = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Container(
          width: 350,
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 27, 29, 31), //Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      child: ProductCardItemCarousel(
                        productUid: widget.product.id,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          BlocConsumer<
                            ProductPricingCubit,
                            ProductPricingState
                          >(
                            listener: (context, state) {
                              if (state is ProductPricingManagerLoaded) {
                                if (state.pricingList.isNotEmpty) {
                                  var myPricing = state.pricingList
                                      .where(
                                        (x) => x.id == widget.product.pricingId,
                                      )
                                      .firstOrNull;
                                  if (myPricing != null) {
                                    productPricing = myPricing;
                                  }
                                }
                              }
                            },
                            builder: (context, state) {
                              return ProductCardPricing(
                                pricingUid: widget.product.pricingId,
                              );
                            },
                          ),
                          Text(
                            widget.inventory.quantityAvailable > 0
                                ? "In Stock"
                                : "Stock out",
                            style: TextStyle(
                              color: widget.inventory.quantityAvailable > 0
                                  ? Colors.greenAccent
                                  : Colors.red,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              inventoryQuantityInfo(
                                "Available",
                                widget.inventory.quantityAvailable,
                              ),
                              inventoryQuantityInfo(
                                "Reserved",
                                widget.inventory.quantityReserved,
                              ),
                              inventoryQuantityInfo(
                                "Sold",
                                widget.inventory.quantitySold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
                listener: (context, state) {
                  if (state is EmitRandomElementSuccessfully) {
                    try {
                      setState(() {
                        var value = (state.element as Map<String, dynamic>);
                        if (value['id'] == "delete_sale") {
                          saleProduct =
                              widget.product.id != value['product_id'];
                        }
                      });
                    } catch (e) {}
                  }
                },
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        saleProduct = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: !saleProduct
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  saleProduct = true;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.grey,
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.grey,
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    "Register Sale",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RegisterSaleForm(
                              productPricing: productPricing!,
                              productSale: widget.product,
                              inventory: widget.inventory,
                              inventoryMetadata: widget.inventoryMetadata,
                            ),
                      //
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  inventoryQuantityInfo(String title, int value) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 4),
          Container(
            width: 50,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                value.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

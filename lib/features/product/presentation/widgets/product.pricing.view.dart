import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/product_pricing/data/models/product.pricing.model.dart';
import 'package:super_manager/features/product_pricing/domain/entities/product.pricing.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../product_pricing/presentation/cubit/product.pricing.cubit.dart';
import '../../../product_pricing/presentation/cubit/product.pricing.state.dart';
import '../../../product_pricing/presentation/widgets/product.pricing.form.page.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';

class ProductPricingView extends StatefulWidget {
  final String productId;
  const ProductPricingView({super.key, required this.productId});

  @override
  State<ProductPricingView> createState() => _ProductPricingViewState();
}

class _ProductPricingViewState extends State<ProductPricingView> {
  String? _productId;
  late List<ProductPricing> myProductPricing;
  late String selectedPricing;

  @override
  void initState() {
    super.initState();
    context.read<ProductPricingCubit>().loadPricing();
    myProductPricing = [];
    _productId = widget.productId;
  }

  void _addProductPricing(ProductPricing? productPricing) {
    showDialog(
      context: context,
      builder: (context) => ProductPricingFormPage(
        productId: widget.productId,
        pricing: productPricing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductPricingCubit, ProductPricingState>(
      listener: (context, state) {
        if (state is ProductPricingManagerLoaded) {
          if (state.pricingList.isNotEmpty) {
            myProductPricing = state.pricingList
                .where((x) => x.productId == _productId)
                .toList();
            final pricing = myProductPricing.where((x) => x.active).firstOrNull;
            if (pricing != null) {
              selectedPricing = pricing.id;
            }
          }
        }
      },
      builder: (context, state) {
        return Row(
          children: [
            BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
              listener: (context, state) {
                if (state is ElementAddedSuccessfully) {
                  setState(() {
                    selectedPricing = state.elementId;
                  });
                }
                if (state is EmitRandomElementSuccessfully) {
                  try {
                    final data = state.element as Map<dynamic, dynamic>;
                    if (data['id'] == 'select_product_pricing') {
                      setState(() {
                        selectedPricing = data['pricing_id']!;
                      });
                      for (var x in myProductPricing) {
                        final pricingMod = ProductPricingModel.fromEntity(x);
                        if (x.id == selectedPricing) {
                          final cp = pricingMod.copyWith(active: true);
                          context.read<ProductPricingCubit>().updatePricing(cp);
                        } else {
                          final cp = pricingMod.copyWith(active: false);
                          context.read<ProductPricingCubit>().updatePricing(cp);
                        }
                      }
                    }
                    // ignore: empty_catches
                  } catch (e) {}
                }
              },
              builder: (context, state) {
                return Container();
              },
            ),
            GestureDetector(
              onTap: () {
                _addProductPricing(null);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(child: Icon(Icons.add)),
              ),
            ),
            SizedBox(width: 10),
            BlocConsumer<ProductPricingCubit, ProductPricingState>(
              listener: (context, state) {},
              builder: (context, state) {
                return myProductPricing.isNotEmpty
                    ? SizedBox(
                        width: 220,
                        height: 55,
                        //decoration: BoxDecoration(color: Colors.amber),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: myProductPricing.map((x) {
                            return GestureDetector(
                              onTap: () {
                                context
                                    .read<WidgetManipulatorCubit>()
                                    .emitRandomElement({
                                      "id": "select_product_pricing",
                                      "pricing_id": x.id,
                                    });
                              },
                              child: Container(
                                width: 80,
                                height: 45,
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedPricing == x.id
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              text: x.amount.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: " DH",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            _addProductPricing(x);
                                          },
                                          child: Container(
                                            width: 17,
                                            height: 17,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : BlocConsumer<
                        WidgetManipulatorCubit,
                        WidgetManipulatorState
                      >(
                        listener: (context, state) {
                          if (state is ElementAddedSuccessfully) {
                            context.read<ProductPricingCubit>().loadPricing();
                          }
                        },
                        builder: (context, state) {
                          return Container(
                            width: 170,
                            height: 60,
                            color: const Color.fromARGB(255, 255, 255, 255),
                            child: Center(
                              child: Text(
                                "No pricing.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ],
        );
      },
    );
  }
}

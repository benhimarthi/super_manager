import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<ProductPricingCubit>().loadPricing();
    myProductPricing = [];
    _productId = widget.productId;
  }

  void _addProductPricing() {
    showDialog(
      context: context,
      builder: (context) => ProductPricingFormPage(productId: widget.productId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductPricingCubit, ProductPricingState>(
      listener: (context, state) {
        if (state is ProductPricingManagerLoaded) {
          myProductPricing = state.pricingList
              .where((x) => x.productId == _productId)
              .toList();
        }
      },
      builder: (context, state) {
        return Row(
          children: [
            GestureDetector(
              onTap: () {
                _addProductPricing();
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
                    ? Row(
                        children: myProductPricing
                            .map(
                              (x) => SizedBox(
                                width: 80,
                                height: 45,
                                //color: Colors.green,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        text: x.amount.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: " DH",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
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

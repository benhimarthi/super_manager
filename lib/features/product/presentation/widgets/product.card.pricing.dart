import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/product_pricing/presentation/cubit/product.pricing.cubit.dart';
import '../../../product_pricing/domain/entities/product.pricing.dart';
import '../../../product_pricing/presentation/cubit/product.pricing.state.dart';

class ProductCardPricing extends StatefulWidget {
  final String pricingUid;
  const ProductCardPricing({super.key, required this.pricingUid});

  @override
  State<ProductCardPricing> createState() => _ProductCardPricingState();
}

class _ProductCardPricingState extends State<ProductCardPricing> {
  late ProductPricing? productPricing;
  @override
  void initState() {
    super.initState();
    productPricing = null;
    context.read<ProductPricingCubit>().loadPricing();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductPricingCubit, ProductPricingState>(
      listener: (context, state) {
        if (state is ProductPricingManagerLoaded) {
          if (state.pricingList.isNotEmpty) {
            var myPricing = state.pricingList
                .where((x) => x.id == widget.pricingUid)
                .firstOrNull;
            //print("@@@@@@@@@@@@@@@@@@@@@@@##################### ${myPricing}");
            if (myPricing != null) {
              productPricing = myPricing;
            }
          }
        }
      },
      builder: (context, state) {
        return productPricing != null
            ? Row(
                children: [
                  Text.rich(
                    TextSpan(
                      text: productPricing!.amount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      children: [
                        TextSpan(
                          text: " DH",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 30),
                  Text.rich(
                    TextSpan(
                      text: productPricing!.discountPercent.toString(),
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: " %",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(child: Icon(Icons.add)),
                  ),
                  SizedBox(width: 10),
                  Text("Add pricing.", style: TextStyle(color: Colors.grey)),
                ],
              );
      },
    );
  }
}

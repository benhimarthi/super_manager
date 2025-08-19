import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/app_theme/app.theme.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';
import 'package:super_manager/features/product/data/models/product.model.dart';
import 'package:super_manager/features/product/presentation/cubit/product.cubit.dart';
import 'package:super_manager/features/product/presentation/pages/product.form.page.dart';
import 'package:super_manager/features/product/presentation/widgets/delete.product.confirmation.screen.dart';
import 'package:super_manager/features/product/presentation/widgets/product.card.category.dart';
import 'package:super_manager/features/product/presentation/widgets/product.card.item.carousel.dart';
import 'package:super_manager/features/product/presentation/widgets/product.card.pricing.dart';
import 'package:super_manager/features/product_category/domain/entities/product.category.dart';
import '../../../product_category/presentation/cubit/local.category.manager.cubit.dart';
import '../../../product_category/presentation/cubit/local.category.manager.state.dart';
import '../../domain/entities/product.dart';

class ProductCardItem extends StatefulWidget {
  final Product product;

  const ProductCardItem({super.key, required this.product});

  @override
  State<ProductCardItem> createState() => _ProductCardItemState();
}

class _ProductCardItemState extends State<ProductCardItem> {
  late List<ProductCategory> myProductCategories;
  late bool productStatus;

  @override
  void initState() {
    super.initState();
    print(widget.product.pricingId);
    myProductCategories = [];
    productStatus = widget.product.active;
    context.read<AppImageManagerCubit>().loadImages(widget.product.id);
  }

  void _deleteProductConfirmationScreen() {
    showDialog(
      context: context,
      builder: (context) =>
          DeleteProductConfirmationScreen(deletedProduct: widget.product),
    );
  }

  void _showProductEditView() {
    showDialog(
      context: context,
      builder: (context) =>
          ProductFormPage(create: false, product: widget.product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showProductEditView();
      },
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          color: productStatus
              ? Color.fromARGB(255, 27, 29, 31)
              : Colors.transparent,
          border: Border.all(color: Color.fromARGB(255, 27, 29, 31)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 100,
                  height: 30,
                  child: Text(
                    widget.product.name,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: "bare code : ",
                    style: TextStyle(color: Colors.white),
                    children: [TextSpan(text: widget.product.barcode)],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    _deleteProductConfirmationScreen();
                  },
                  child: Container(
                    height: 18,
                    width: 18,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(child: Icon(Icons.close, size: 16)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductCardItemCarousel(productUid: widget.product.id),
                SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductCardPricing(pricingUid: widget.product.pricingId),
                    SizedBox(height: 15),
                    BlocConsumer<
                      LocalCategoryManagerCubit,
                      LocalCategoryManagerState
                    >(
                      listener: (context, state) {
                        if (state is LocalCategoryManagerLoaded) {
                          setState(() {
                            myProductCategories = state.categories;
                          });
                        }
                      },
                      builder: (context, state) {
                        return ProductCardCategory(
                          categoryId: widget.product.categoryId,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Product status : ",
                  style: TextStyle(
                    color: productStatus
                        ? AppTheme.activatedStatusColor
                        : AppTheme.deactivatedStatusColor,
                  ),
                ),
                Transform.scale(
                  scale: .5,
                  child: Switch(
                    value: productStatus,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() {
                        productStatus = val;
                        var updatedProduct = ProductModel.fromEntity(
                          widget.product,
                        ).copyWith(active: val);
                        context.read<ProductCubit>().updateProduct(
                          updatedProduct,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

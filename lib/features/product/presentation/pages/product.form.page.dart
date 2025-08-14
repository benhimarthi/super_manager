import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/session/session.manager.dart';
import 'package:super_manager/features/image_manager/domain/entities/app.image.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.state.dart';
import 'package:super_manager/features/product/presentation/widgets/product.profile.image.dart';
import 'package:super_manager/features/product_category/domain/entities/product.category.dart';
import 'package:super_manager/features/product_category/presentation/pages/category.form.page.dart';
import 'package:uuid/uuid.dart';
import '../../../product_category/presentation/cubit/local.category.manager.cubit.dart';
import '../../../product_category/presentation/cubit/local.category.manager.state.dart';
import '../../../product_category/presentation/widgets/selecting.parent.category.dart';
import '../../../product_pricing/presentation/cubit/product.pricing.cubit.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import '../../domain/entities/product.dart';
import 'product.second.form.page.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  final bool create;

  const ProductFormPage({super.key, this.product, required this.create});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _name;
  late TextEditingController _description;
  String? _selectedCategoryId;
  late String productUid;
  late ProductCategory? productCategory;
  late int page = 0;
  late List<AppImage> myProductImages;
  late List<String> myCachedImages;
  late Product? cachedProduct;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    myProductImages = [];
    myCachedImages = [];
    var product = widget.product;
    productUid = widget.product != null ? widget.product!.id : Uuid().v4();
    _name = TextEditingController(text: product?.name ?? '');
    _description = TextEditingController(text: product?.description ?? '');
    productCategory = null;
    cachedProduct = null;
    _selectedCategoryId = "";
    context.read<ProductPricingCubit>().loadPricing();
    context.read<LocalCategoryManagerCubit>().loadCategories();
  }

  initialazeImageModel(String imageUrl) {
    return AppImage(
      id: Uuid().v4(),
      url: imageUrl,
      entityId: productUid,
      uploadedBy: SessionManager.getUserSession()!.id,
      entityType: "product_item",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    var updatedProd = widget.product;
    final product = Product(
      id: productUid,
      name: _name.text.trim(),
      description: _description.text.trim(),
      categoryId: _selectedCategoryId ?? "",
      unit: updatedProd != null ? updatedProd.unit : "",
      barcode: updatedProd != null ? updatedProd.barcode : "",
      imageUrl: "",
      pricingId: updatedProd != null ? updatedProd.pricingId : "",
      active: updatedProd != null ? updatedProd.active : false,
      creatorID: SessionManager.getUserSession()!.id,
      createdAt: widget.product?.createdAt ?? now,
      updatedAt: now,
    );
    setState(() {
      cachedProduct = product;
    });
    context.read<WidgetManipulatorCubit>().cacheProduct(product);
    setState(() {
      page = 1;
    });
  }

  void _editProductCategory() {
    showDialog(context: context, builder: (context) => CategoryFormPage());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.product == null ? 'Add Product' : 'Edit Product',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (page == 0 && formKey.currentState!.validate()) {
                  _submit();
                  page = 1;
                  return;
                }
                if (page == 1) {
                  setState(() {
                    page = 0;
                    myCachedImages = myProductImages.map((x) => x.url).toList();
                  });
                }
              });
            },
            child: Text(
              page == 0 ? "Next" : "Prev",
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
        ],
      ),
      content: page == 0
          ? SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "Upload Images",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        BlocConsumer<AppImageManagerCubit, AppImageState>(
                          listener: (context, state) {
                            if (state is OpenImageFromGalerySuccessfully) {
                              if (state.imageLink != null) {
                                myProductImages.add(
                                  initialazeImageModel(state.imageLink!.path),
                                );
                              }
                            }
                          },
                          builder: (context, state) {
                            return ProductProfileImage(
                              productId: widget.product != null
                                  ? widget.product!.id
                                  : "",
                              cahedImages: myCachedImages,
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Select category",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              padding: EdgeInsets.all(5),
                              child:
                                  BlocConsumer<
                                    LocalCategoryManagerCubit,
                                    LocalCategoryManagerState
                                  >(
                                    listener: (context, state) {
                                      if (state is LocalCategoryManagerLoaded) {
                                        if (widget.product != null) {
                                          final targetCategory = state
                                              .categories
                                              .where(
                                                (x) =>
                                                    x.id ==
                                                    widget.product!.categoryId,
                                              )
                                              .firstOrNull;
                                          if (targetCategory != null) {
                                            setState(() {
                                              productCategory = targetCategory;
                                              _selectedCategoryId =
                                                  productCategory!.id;
                                            });
                                          }
                                        }
                                      }
                                    },
                                    builder: (context, state) {
                                      return Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _editProductCategory();
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.add,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: 172,
                              child:
                                  BlocConsumer<
                                    WidgetManipulatorCubit,
                                    WidgetManipulatorState
                                  >(
                                    listener: (context, state) {
                                      if (state
                                          is SelectingProductCategorySuccessfully) {
                                        _selectedCategoryId = state.categoryuid;
                                      }
                                      if (state is LocalCategoryManagerLoaded) {
                                        setState(() {});
                                      }
                                    },
                                    builder: (context, state) {
                                      return SelectingParentCategory(
                                        categoryUid: widget.product != null
                                            ? widget.product!.categoryId
                                            : (cachedProduct != null
                                                  ? cachedProduct!.categoryId
                                                  : ""),
                                        useInProduct: true,
                                      );
                                    },
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Form(
                          key: formKey,
                          child: TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(
                              labelText: 'Product title',
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'A product title is Required!'
                                : null,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _description,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                        ),
                        SizedBox(height: 20),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : ProductSecondFormPage(
              myProductImages: myProductImages,
              creation: widget.create,
            ),
    );
  }
}

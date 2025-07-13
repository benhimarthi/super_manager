import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/image_manager/domain/entities/app.image.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';
import '../../../image_manager/presentation/cubit/app.image.state.dart';
import '../../../product_category/domain/entities/product.category.dart';
import '../../../product_category/presentation/cubit/local.category.manager.cubit.dart';
import '../../../product_category/presentation/cubit/local.category.manager.state.dart';

class ProductCardCategory extends StatefulWidget {
  final String categoryId;

  const ProductCardCategory({super.key, required this.categoryId});

  @override
  State<ProductCardCategory> createState() => _ProductCardCategoryState();
}

class _ProductCardCategoryState extends State<ProductCardCategory> {
  late List<ProductCategory> myProductCategories;
  late AppImage? categoryImage;
  @override
  void initState() {
    super.initState();
    myProductCategories = [];
    categoryImage = null;
    context.read<LocalCategoryManagerCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocalCategoryManagerCubit, LocalCategoryManagerState>(
      listener: (context, state) {
        if (state is LocalCategoryManagerLoaded) {
          setState(() {
            myProductCategories = state.categories
                .where((x) => x.id == widget.categoryId)
                .toList();
            var category = myProductCategories.firstOrNull;
            if (category != null) {
              context.read<AppImageManagerCubit>().loadImages(category.id);
            }
          });
        }
      },
      builder: (context, state) {
        return BlocConsumer<AppImageManagerCubit, AppImageState>(
          listener: (context, state) {
            if (state is AppImageManagerLoaded) {
              var myCategory = myProductCategories.firstOrNull;
              if (myCategory != null) {
                var myCategoryImage = state.images
                    .where((x) => x.entityId == myCategory.id)
                    .firstOrNull;
                if (myCategoryImage != null) {
                  categoryImage = myCategoryImage;
                }
              }
            }
          },
          builder: (context, state) {
            return categoryImage != null && categoryImage!.url.isNotEmpty
                ? Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: CircleAvatar(
                              backgroundColor: Colors.black,
                              radius: 12,
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(categoryImage!.url)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 6),
                      Text(
                        myProductCategories.first.name,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ],
                  )
                : Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
          },
        );
      },
    );
  }
}

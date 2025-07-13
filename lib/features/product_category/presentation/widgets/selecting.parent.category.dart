import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/image_manager/domain/entities/app.image.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../../core/service/depenedancy.injection.dart';
import '../../../image_manager/presentation/cubit/app.image.state.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import '../../domain/entities/product.category.dart';
import '../../domain/usecases/get.all.product.categories.dart';

class SelectingParentCategory extends StatefulWidget {
  final ProductCategory? category;
  final String? categoryUid;
  final bool? useInProduct;

  const SelectingParentCategory({
    super.key,
    this.category,
    this.categoryUid,
    this.useInProduct,
  });

  @override
  State<SelectingParentCategory> createState() =>
      _SelectingParentCategoryState();
}

class _SelectingParentCategoryState extends State<SelectingParentCategory> {
  late Set<String> imageUrl;
  late String selectedCategory = "";
  late List<File> myImages;
  late Set<AppImage> ids;

  Future<List<ProductCategory>> _loadParentOptions() async {
    imageUrl = {};
    final result = await getIt<GetAllProductCategories>()();

    return result.fold((_) => [], (categories) {
      // Exclude self to prevent circular parenting
      return widget.category == null
          ? categories
          : categories.where((c) => c.id != widget.category!.id).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.categoryUid!;
    context.read<AppImageManagerCubit>().getImagesFromDirectory('product');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductCategory>>(
      future: _loadParentOptions(),
      builder: (_, snapshot) {
        final items = snapshot.data ?? [];
        return items.isNotEmpty
            ? SizedBox(
                width: 300,
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(items.length, (index) {
                    var currentCategory = items[index];
                    context.read<AppImageManagerCubit>().loadCategoryImages(
                      currentCategory.id,
                    );
                    return BlocConsumer<AppImageManagerCubit, AppImageState>(
                      listener: (context, state) {
                        if (state is AppImageCategoryLoaded) {
                          var image = state.images.firstOrNull;
                          if (image != null) {
                            imageUrl.add(image.url);
                          }
                        }
                        if (state is LoadedAllImagesFromDirectorySuccessfully) {
                          myImages = state.images;
                        }
                      },
                      builder: (context, state) {
                        if (imageUrl.isNotEmpty) {
                          return BlocConsumer<
                            WidgetManipulatorCubit,
                            WidgetManipulatorState
                          >(
                            listener: (context, state) {
                              if (state
                                  is SelectingProductCategorySuccessfully) {
                                setState(() {
                                  selectedCategory = state.categoryuid;
                                });
                              }
                            },
                            builder: (context, state) {
                              return productCategoryItem(
                                currentCategory.name,
                                index < imageUrl.length &&
                                        imageUrl.elementAt(index).isEmpty
                                    ? ""
                                    : imageUrl.elementAt(index),
                                selectedCategory == currentCategory.id,
                                () {
                                  setState(() {
                                    if (selectedCategory !=
                                        currentCategory.id) {
                                      context
                                          .read<WidgetManipulatorCubit>()
                                          .selectProductCategory(
                                            currentCategory.name,
                                            currentCategory.id,
                                          );
                                    } else {
                                      selectedCategory = "";
                                    }
                                  });
                                },
                                context,
                              );
                            },
                          );
                        } else {
                          return Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    221,
                                    221,
                                    221,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              Text(currentCategory.name),
                            ],
                          );
                        }
                      },
                    );
                  }),
                ),
              )
            : Container(
                width: double.infinity,
                height: 45,
                color: Colors.white,
                child: Center(
                  child: Text(
                    "There's no Category.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
      },
    );
  }

  productCategoryItem(name, String imageUrl, isSelected, onTap, context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color.fromARGB(123, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 3,
                ),
              )
            : BoxDecoration(),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: imageUrl.isNotEmpty
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(image: FileImage(File(imageUrl))),
                    )
                  : BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5),
                    ),
            ),
            Text(
              name,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : const Color.fromARGB(255, 182, 182, 182),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

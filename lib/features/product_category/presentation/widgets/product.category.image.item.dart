import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';

import '../../../image_manager/domain/entities/app.image.dart';
import '../../../image_manager/presentation/cubit/app.image.state.dart';

class ProductCategoryImageItem extends StatefulWidget {
  final String categoryUid;
  const ProductCategoryImageItem({super.key, required this.categoryUid});

  @override
  State<ProductCategoryImageItem> createState() =>
      _ProductCategoryImageItemState();
}

class _ProductCategoryImageItemState extends State<ProductCategoryImageItem> {
  late AppImage? categoryIamge;
  @override
  void initState() {
    super.initState();
    categoryIamge = null;
    context.read<AppImageManagerCubit>().loadCategoryImages(widget.categoryUid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppImageManagerCubit, AppImageState>(
      listener: (context, state) {
        if (state is AppImageCategoryLoaded) {
          var catImage = state.images.firstOrNull;
          if (catImage != null) {
            if (catImage.entityId == widget.categoryUid) {
              categoryIamge = catImage;
              //print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ${categoryIamge}");
            }
          }
        }
      },
      builder: (context, state) {
        return Container(
          height: 20,
          width: 20,
          decoration: categoryIamge == null
              ? BoxDecoration(
                  color: const Color.fromARGB(255, 43, 41, 41),
                  borderRadius: BorderRadius.circular(20),
                )
              : BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(categoryIamge!.url)),
                  ),
                ),
        );
      },
    );
  }
}

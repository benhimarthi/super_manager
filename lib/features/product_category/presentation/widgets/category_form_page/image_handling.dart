import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/image_manager/domain/entities/app.image.dart';

import '../../../../image_manager/presentation/cubit/app.image.cubit.dart';
import '../../../../image_manager/presentation/cubit/app.image.state.dart';
import '../../../../image_manager/presentation/widgets/profile.image.dart';
import '../../../domain/entities/product.category.dart';

class ImageHandlingWidget extends StatelessWidget {
  final bool displayable;
  final ProductCategory? category;
  final String categoryId;
  final Function(bool) onUpdated;
  final Function(File?, AppImage?) onImageChanged;

  const ImageHandlingWidget({
    super.key,
    required this.displayable,
    required this.category,
    required this.categoryId,
    required this.onUpdated,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppImageManagerCubit, AppImageState>(
      listener: (context, state) {
        if (state is AppImageCategoryLoaded) {
          var catImage = state.images.firstOrNull;
          if (catImage != null) {
            if (catImage.entityId == categoryId) {
              onImageChanged(File(catImage.url), catImage);
            }
          }
        }
        if (state is OpenImageFromGalerySuccessfully) {
          if (state.imageLink != null) {
            onImageChanged(state.imageLink, null);
          }
        }
      },
      builder: (context, state) {
        return displayable
            ? SizedBox(
                height: 50,
                width: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: state is OpenImageFromGalerySuccessfully
                          ? Image.file(state.imageLink!)
                          : ProfileImage(
                              itemId: categoryId,
                              entityType: "category",
                              name: category?.name ?? '',
                              radius: 18,
                              fontSize: 16,
                              displayEdit: false,
                            ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          context
                              .read<AppImageManagerCubit>()
                              .openImageFromGalery("product")
                              .whenComplete(() {});
                          onUpdated(true);
                        },
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Center(
                            child: Icon(Icons.refresh, size: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : GestureDetector(
                onTap: () {
                  context
                      .read<AppImageManagerCubit>()
                      .openImageFromGalery("product")
                      .whenComplete(() {});
                  onUpdated(true);
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(149, 158, 158, 158),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              );
      },
    );
  }
}

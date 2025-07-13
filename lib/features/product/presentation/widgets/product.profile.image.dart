import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/util/circular.list.navigator.dart';
import '../../../image_manager/domain/entities/app.image.dart';
import '../../../image_manager/presentation/cubit/app.image.cubit.dart';
import '../../../image_manager/presentation/cubit/app.image.state.dart';

class ProductProfileImage extends StatefulWidget {
  final String productId;
  const ProductProfileImage({super.key, required this.productId});

  @override
  State<ProductProfileImage> createState() => _ProductProfileImageState();
}

class _ProductProfileImageState extends State<ProductProfileImage> {
  late String productId;
  late bool displayable;
  late bool isUpdated;
  late File? productImageFile;
  late List<String> myProductImages;
  late List<String> existingIamges;
  late CircularListNavigator listNavigator;
  late bool addProductProfileImage = false;
  late List<AppImage> myAppProductImages;

  @override
  void initState() {
    super.initState();
    displayable = false;
    productId = widget.productId;
    myProductImages = [];
    myAppProductImages = [];
    existingIamges = [];
    if (myProductImages.isNotEmpty) {
      listNavigator = CircularListNavigator(existingIamges);
    }
    if (productId.isNotEmpty) {
      context.read<AppImageManagerCubit>().loadProductImages(widget.productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 100,
              height: 100,
              decoration: displayable
                  ? BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(existingIamges.first)),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 213, 213, 213),
                    )
                  : BoxDecoration(
                      color: const Color.fromARGB(255, 213, 213, 213),
                      borderRadius: BorderRadius.circular(10),
                    ),
            ),
          ),
          Align(
            alignment: Alignment(0.3, 0.3),
            child: BlocConsumer<AppImageManagerCubit, AppImageState>(
              listener: (context, state) {
                if (state is AppImageProductLoaded) {
                  final myImages = state.images
                      .where((x) => x.entityId == widget.productId)
                      .toList();
                  if (myImages.isNotEmpty) {
                    myAppProductImages = myImages;
                    existingIamges = myImages.map((x) => x.url).toList();
                    displayable = true;
                    listNavigator = CircularListNavigator(existingIamges);
                    productImageFile = File(existingIamges.first);
                  }
                }
                if (state is OpenImageFromGalerySuccessfully) {
                  if (state.imageLink != null && addProductProfileImage) {
                    setState(() {
                      productImageFile = state.imageLink;
                      displayable = state.imageLink!.path.isNotEmpty;
                      myProductImages.add(state.imageLink!.path);
                      existingIamges.add(state.imageLink!.path);
                      listNavigator = CircularListNavigator(existingIamges);
                      addProductProfileImage = false;
                    });
                  }
                }
                if (state is DeleteImageFromDirectorySuccessfully) {
                  setState(() {
                    myProductImages.removeWhere(
                      (x) => x == productImageFile!.path,
                    );
                    existingIamges.removeWhere(
                      (x) => x == productImageFile!.path,
                    );
                    if (existingIamges.isEmpty) {
                      displayable = false;
                    } else {
                      listNavigator = CircularListNavigator(existingIamges);
                      productImageFile = File(existingIamges.first);
                    }
                  });
                }
              },
              builder: (context, state) {
                /*if (state is AppImageManagerLoaded ||
                    state is DeleteImageFromDirectorySuccessfully) {
                  return displayable
                      ? Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(productImageFile!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.photo,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        );
                } else {
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.photo,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  );
                }*/
                return displayable
                    ? Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(productImageFile!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.photo,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                context
                    .read<AppImageManagerCubit>()
                    .openImageFromGalery("product_item")
                    .whenComplete(() {
                      setState(() {});
                    });
                isUpdated = true;
                addProductProfileImage = true;
              },
              child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Center(child: Icon(Icons.add)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Visibility(
              visible: existingIamges.isNotEmpty,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    var deletedImage = myAppProductImages
                        .where((x) => x.url == productImageFile!.path)
                        .firstOrNull;
                    if (deletedImage != null) {
                      context.read<AppImageManagerCubit>().deleteImage(
                        deletedImage.id,
                        deletedImage.entityId,
                      );
                      String imageName = deletedImage.url.split("/").last;
                      context
                          .read<AppImageManagerCubit>()
                          .removeImageFromDirectory(
                            imageName,
                            deletedImage.entityType,
                          );
                    }
                  });
                },
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Center(
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Visibility(
              visible: existingIamges.length > 1,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    listNavigator.next();
                    productImageFile = File(listNavigator.current.toString());
                  });
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  child: Center(
                    child: Icon(Icons.arrow_forward_ios_outlined, size: 16),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Visibility(
              visible: existingIamges.length > 1,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    listNavigator.previous();
                    productImageFile = File(listNavigator.current.toString());
                  });
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  child: Center(
                    child: Icon(Icons.arrow_back_ios_new, size: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

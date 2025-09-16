import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/util/circular.list.navigator.dart';
import 'package:super_manager/features/image_manager/domain/entities/app.image.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';

import '../../../image_manager/presentation/cubit/app.image.state.dart';

class ProductCardItemCarousel extends StatefulWidget {
  final String productUid;
  final String elementName;
  const ProductCardItemCarousel({
    super.key,
    required this.productUid,
    required this.elementName,
  });

  @override
  State<ProductCardItemCarousel> createState() =>
      _ProductCardItemCarouselState();
}

class _ProductCardItemCarouselState extends State<ProductCardItemCarousel> {
  late List<AppImage> productImages;
  Timer? _syncTimer;
  late CircularListNavigator carousel;
  late String currentImageUrl = "";
  late int currentCarouselDot = 0;

  @override
  void initState() {
    super.initState();
    productImages = [];
    context.read<AppImageManagerCubit>().loadImages(widget.productUid);
    startSyncing();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  void startSyncing() {
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (productImages.length > 1) {
        setState(() {
          carousel.next();
          currentImageUrl = carousel.current.url;
          currentCarouselDot = (currentCarouselDot + 1) % 3;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppImageManagerCubit, AppImageState>(
      listener: (context, state) {
        if (state is AppImageManagerLoaded) {
          if (state.images.isNotEmpty) {
            productImages = productImages.isEmpty
                ? state.images
                      .where((x) => x.entityId == widget.productUid)
                      .toList()
                : productImages;
            currentImageUrl = productImages.isNotEmpty
                ? productImages.first.url
                : "";
            if (productImages.length >= 2) {
              carousel = CircularListNavigator(productImages);
            }
          }
        }
      },
      builder: (context, state) {
        final file = File(currentImageUrl);
        return currentImageUrl == "" || !file.existsSync()
            ? Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    widget.elementName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                /*Icon(Icons.image,
                color: Theme.of(context).primaryColor),*/
              )
            : Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(file),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Visibility(
                        visible: productImages.length > 1,
                        child: SizedBox(
                          width: 40,
                          height: 20,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(
                                3,
                                (ind) => CircleAvatar(
                                  radius: 2,
                                  backgroundColor: currentCarouselDot == ind
                                      ? Theme.of(context).primaryColor
                                      : Color.fromARGB(122, 159, 122, 234),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}

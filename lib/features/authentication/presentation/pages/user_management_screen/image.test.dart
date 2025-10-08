import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/image_storage_service/image.storage.service.dart';
import '../../../../../core/service/depenedancy.injection.dart';

class ImageTest extends StatefulWidget {
  const ImageTest({super.key});

  @override
  State<ImageTest> createState() => _ImageTestState();
}

class _ImageTestState extends State<ImageTest> {
  final storage = getIt<ImageStorageService>();
  File? image;
  getImage() async {
    image = await storage.pickAndSaveImage("test_img").whenComplete(() {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    storage.clearAllImages("test_img");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: GestureDetector(
          onTap: () async {
            setState(() {
              getImage();
            });
          },
          child: Builder(
            builder: (cntx) {
              return Container(
                height: 100,
                width: 100,
                color: Colors.amber,
                child: image != null
                    ? Image.file(image!, height: 100)
                    : const SizedBox(),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.state.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/session/session.manager.dart';
import '../../data/models/app.image.model.dart';

class ProfileImage extends StatefulWidget {
  final String itemId;
  final String entityType;
  final String name;
  final bool displayEdit;
  final double radius;
  final double fontSize;
  const ProfileImage({
    super.key,
    required this.itemId,
    required this.entityType,
    required this.name,
    this.displayEdit = true,
    required this.radius,
    required this.fontSize,
  });

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  File? image;
  final _uuid = const Uuid();
  late AppImageModel avatar;

  @override
  void initState() {
    super.initState();
    avatar = AppImageModel.empty();
    context.read<AppImageManagerCubit>().loadProfileImages(widget.itemId);
  }

  updateProfileImge(String url) {
    final newAvatar = AppImageModel(
      id: _uuid.v4(),
      url: url,
      entityId: widget.itemId,
      entityType: widget.entityType, //"profile",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      position: (avatar.position ?? 0) + 1,
      uploadedBy: widget.itemId,
      adminId: SessionManager.getUserSession()!.administratorId != null
          ? SessionManager.getUserSession()!.administratorId!
          : SessionManager.getUserSession()!.id,
    );
    context.read<AppImageManagerCubit>().createImage(newAvatar).whenComplete(
      () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          BlocConsumer<AppImageManagerCubit, AppImageState>(
            listener: (context, state) {
              if (state is OpenProfileImageFromGalerySuccessfully) {
                setState(() {
                  image = state.imageLink;
                  updateProfileImge(image!.path);
                });
              }
              if (state is GetAppImageByIdSuccessfully) {
                if (state.image.url.isNotEmpty) {
                  image = File(state.image.url);
                }
              }
              if (state is AppImageProfileLoaded) {
                if (state.images.isNotEmpty) {
                  final toDisplay = state.images
                      .where((x) => x.url.isNotEmpty && x.active)
                      .lastOrNull;

                  if (toDisplay != null) {
                    avatar = toDisplay as AppImageModel;
                    image = File(toDisplay.url);
                  } else {
                    avatar = AppImageModel.empty();
                  }
                }
              }
            },
            builder: (context, state) {
              return image != null
                  ? CircleAvatar(
                      radius: widget.radius,
                      backgroundColor: Colors.white,
                      backgroundImage: FileImage(image!),
                    )
                  : CircleAvatar(
                      radius: widget.radius,
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.name[0],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: widget.fontSize,
                        ),
                      ),
                    );
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Visibility(
              visible: widget.displayEdit,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    context
                        .read<AppImageManagerCubit>()
                        .openProfileImageFromGalery('profile')
                        .whenComplete(() {
                          setState(() {});
                        });
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(width: 3),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

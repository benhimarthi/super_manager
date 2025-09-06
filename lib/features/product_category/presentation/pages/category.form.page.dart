import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/image_manager/data/models/app.image.model.dart';
import 'package:super_manager/features/image_manager/domain/entities/app.image.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';
import 'package:super_manager/features/product_category/presentation/widgets/selecting.parent.category.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/session/session.manager.dart';
import '../../../image_manager/presentation/cubit/app.image.state.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import '../../domain/entities/product.category.dart';
import '../cubit/local.category.manager.cubit.dart';
import '../cubit/local.category.manager.state.dart';

class CategoryFormPage extends StatefulWidget {
  final ProductCategory? category; // null for create mode

  const CategoryFormPage({super.key, this.category});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  ProductCategory? _selectedParent;
  IconData? _selectedIcon;
  late AppImage? categoryImage;
  late File? categoryImageFile;
  late String categoryId;
  late bool displayable = false;
  late bool isUpdated = false;
  late String parentCategoryUid;
  late String parentCategoryName;
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    parentCategoryUid = "";
    parentCategoryName = "";
    categoryImage = null;
    _name = TextEditingController(text: cat?.name ?? '');
    _description = TextEditingController(text: cat?.description ?? '');
    _selectedIcon = widget.category?.iconCodePoint != null
        ? IconData(widget.category!.iconCodePoint!, fontFamily: 'MaterialIcons')
        : null;

    if (cat != null && cat.parentId != null) {
      // Load parent reference for dropdown

      categoryId = cat.id;
      final state = context.read<LocalCategoryManagerCubit>().state;
      final allCategories = state is LocalCategoryManagerLoaded
          ? state.categories
          : [];

      try {
        _selectedParent = allCategories.firstWhere((c) => c.id == cat.parentId);
        parentCategoryName = _selectedParent!.name;
        parentCategoryUid = _selectedParent!.id;
      } catch (_) {
        _selectedParent = null; // No match found
      }
      context.read<AppImageManagerCubit>().loadCategoryImages(cat.id);
    } else {
      categoryId = _uuid.v4();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    var categoryImg = updateCategoryImage(
      categoryImageFile != null ? categoryImageFile!.path : "",
    );
    final isNew = widget.category == null;
    final newCategory = ProductCategory(
      id: widget.category?.id ?? categoryId, // generate ID for new entries
      name: _name.text.trim(),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      parentId: parentCategoryUid,
      imageUrl: categoryImg!.id,
      iconCodePoint: _selectedIcon?.codePoint,
      isActive: true,
      createdAt: widget.category?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      adminId: SessionManager.getUserSession()!.administratorId != null
          ? SessionManager.getUserSession()!.administratorId!
          : SessionManager.getUserSession()!.id,
    );
    if (isUpdated &&
        categoryImageFile != null &&
        categoryImageFile!.path.isNotEmpty) {
      context.read<AppImageManagerCubit>().createImage(categoryImg);
    }
    final cubit = context.read<LocalCategoryManagerCubit>();
    isNew
        ? cubit.addCategory(newCategory).whenComplete(() {
            setState(() {
              cubit.loadCategories();
            });
          })
        : cubit.updateCategory(newCategory);

    Navigator.pop(context); // return to list after submission
  }

  updateCategoryImage(String imageUrl) {
    if (categoryImage != null) {
      var updatedImage = (categoryImage as AppImageModel).copyWith(
        url: imageUrl,
      );
      context.read<AppImageManagerCubit>().updateImage(updatedImage);
    } else {
      return AppImage(
        id: _uuid.v4(),
        url: imageUrl,
        entityId: categoryId,
        entityType: "product",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        adminId: SessionManager.getUserSession()!.administratorId != null
            ? SessionManager.getUserSession()!.administratorId!
            : SessionManager.getUserSession()!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return AlertDialog(
      title: Text(
        isEdit ? 'EDIT CATEGORY' : 'NEW CATEGORY',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Add image",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 10),
                  BlocConsumer<AppImageManagerCubit, AppImageState>(
                    listener: (context, state) {
                      if (state is AppImageCategoryLoaded) {
                        var catImage = state.images.firstOrNull;
                        if (catImage != null) {
                          if (catImage.entityId == categoryId) {
                            displayable = catImage.url.isNotEmpty;
                            categoryImageFile = File(categoryImage!.url);
                            categoryImage = catImage;
                          }
                        }
                      }
                      if (state is OpenImageFromGalerySuccessfully) {
                        if (state.imageLink != null) {
                          displayable = true;
                          categoryImageFile = state.imageLink;
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
                                      image: DecorationImage(
                                        image: FileImage(categoryImageFile!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        context
                                            .read<AppImageManagerCubit>()
                                            .openImageFromGalery("product")
                                            .whenComplete(() {
                                              setState(() {});
                                            });
                                        isUpdated = true;
                                      },
                                      child: CircleAvatar(
                                        radius: 9,
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        child: Center(
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
                                    .whenComplete(() {
                                      setState(() {});
                                    });
                                isUpdated = true;
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      149,
                                      158,
                                      158,
                                      158,
                                    ),
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
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Select parent category",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(height: 10),
                  BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
                    listener: (context, state) {
                      if (state is SelectingProductCategorySuccessfully) {
                        parentCategoryUid = state.categoryuid;
                      }
                    },
                    builder: (context, state) {
                      return SelectingParentCategory(
                        category: widget.category,
                        categoryUid: parentCategoryName,
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _description,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: Icon(isEdit ? Icons.save : Icons.add),
                    label: Text(isEdit ? 'Save Changes' : 'Create Category'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

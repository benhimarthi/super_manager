import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/image_manager/data/models/app.image.model.dart';
import 'package:super_manager/features/image_manager/domain/entities/app.image.dart';
import 'package:super_manager/features/product_category/presentation/widgets/category_form_page/image_handling.dart';
import 'package:super_manager/features/product_category/presentation/widgets/category_form_page/parent_category_selector.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/session/session.manager.dart';
import '../../../image_manager/presentation/cubit/app.image.cubit.dart';
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
  AppImage? categoryImage;
  File? categoryImageFile;
  late String categoryId;
  bool isUpdated = false;
  late String parentCategoryUid;
  late String parentCategoryName;
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    parentCategoryUid = "";
    parentCategoryName = "";
    _name = TextEditingController(text: cat?.name ?? '');
    _description = TextEditingController(text: cat?.description ?? '');
    _selectedIcon = widget.category?.iconCodePoint != null
        ? IconData(widget.category!.iconCodePoint!, fontFamily: 'MaterialIcons')
        : null;

    if (cat != null) {
      categoryId = cat.id;
      if (cat.parentId != null) {
        final state = context.read<LocalCategoryManagerCubit>().state;
        final allCategories = state is LocalCategoryManagerLoaded ? state.categories : [];
        try {
          _selectedParent = allCategories.firstWhere((c) => c.id == cat.parentId);
          parentCategoryName = _selectedParent!.name;
          parentCategoryUid = _selectedParent!.id;
        } catch (_) {
          _selectedParent = null; // No match found
        }
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

    AppImage? categoryImg;
    if (categoryImageFile != null) {
      categoryImg = updateCategoryImage(categoryImageFile!.path);
    }

    final isNew = widget.category == null;
    final newCategory = ProductCategory(
      id: widget.category?.id ?? categoryId,
      name: _name.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      parentId: parentCategoryUid,
      imageUrl: categoryImg?.id,
      iconCodePoint: _selectedIcon?.codePoint,
      isActive: true,
      createdAt: widget.category?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      adminId: SessionManager.getUserSession()!.administratorId ?? SessionManager.getUserSession()!.id,
    );

    if (isUpdated && categoryImageFile != null && categoryImageFile!.path.isNotEmpty) {
      if (categoryImg != null) {
        context.read<AppImageManagerCubit>().createImage(categoryImg);
      }
    }

    final cubit = context.read<LocalCategoryManagerCubit>();
    if (isNew) {
      cubit.addCategory(newCategory).whenComplete(() {
        cubit.loadCategories();
      });
    } else {
      cubit.updateCategory(newCategory);
    }

    Navigator.pop(context);
  }

  AppImage? updateCategoryImage(String imageUrl) {
    if (categoryImage != null) {
      var updatedImage = (categoryImage as AppImageModel).copyWith(url: imageUrl);
      context.read<AppImageManagerCubit>().updateImage(updatedImage);
      return updatedImage;
    } else {
      final newImage = AppImage(
        id: _uuid.v4(),
        url: imageUrl,
        entityId: categoryId,
        entityType: "product",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        adminId: SessionManager.getUserSession()!.administratorId ?? SessionManager.getUserSession()!.id,
      );
      return newImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return AlertDialog(
      title: Text(
        isEdit ? 'EDIT CATEGORY' : 'NEW CATEGORY',
        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add image", style: TextStyle(color: Theme.of(context).primaryColor)),
              const SizedBox(height: 10),
              ImageHandlingWidget(
                displayable: categoryImageFile != null,
                category: widget.category,
                categoryId: categoryId,
                onUpdated: (updated) => setState(() => isUpdated = updated),
                onImageChanged: (file, image) {
                  setState(() {
                    if (file != null) categoryImageFile = file;
                    if (image != null) categoryImage = image;
                  });
                },
              ),
              const SizedBox(height: 10),
              Text("Select parent category", style: TextStyle(color: Theme.of(context).primaryColor)),
              const SizedBox(height: 10),
              ParentCategorySelector(
                category: widget.category,
                parentCategoryName: parentCategoryName,
                onParentCategoryChanged: (uid) => setState(() => parentCategoryUid = uid),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 10),
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
      ),
    );
  }
}

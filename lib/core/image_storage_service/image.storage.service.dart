import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:super_manager/core/errors/custom.exception.dart';
import 'package:super_manager/core/errors/failure.dart';
import 'package:super_manager/core/util/typedef.dart';
import 'package:uuid/uuid.dart';

class ImageStorageService {
  final _uuid = const Uuid();
  final _picker = ImagePicker();

  /// Internal app directory for protected image storage
  Future<Directory> getSafeDirectory(String imagePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final safeDir = Directory('${dir.path}/my_protected_images/$imagePath');
    if (!await safeDir.exists()) {
      await safeDir.create(recursive: true);
    }
    return safeDir;
  }

  /// Pick an image from the gallery and save it with a random UUID name.
  /// Returns the saved File (or null if user cancels)
  Future<File?> pickAndSaveImage(String dirName) async {
    try {
      final isGranted = await _requestGalleryPermission();
      if (!isGranted) return null;

      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return null;

      final originalFile = File(picked.path);
      final ext = path.extension(picked.path);
      final newName = '${_uuid.v4()}$ext';

      final safeDir = await getSafeDirectory(dirName);
      final savedFile = File('${safeDir.path}/$newName');

      return await originalFile.copy(savedFile.path);
    } on LocalException catch (e) {
      throw LocalException(message: e.message, statusCode: 500);
    }
  }

  ResultFuture<File?> pick(String name) async {
    try {
      final result = await pickAndSaveImage(name);
      return Right(result);
    } on LocalException catch (e) {
      return Left(LocalFailure.fromLocalException(e));
    }
  }

  /// Request storage/photo access based on platform
  Future<bool> _requestGalleryPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted) return true;

      final status = await Permission.photos.request();
      return status.isGranted;
    }

    if (Platform.isIOS) {
      if (await Permission.photos.isGranted) return true;

      final status = await Permission.photos.request();
      return status.isGranted;
    }

    return false; // Fallback for unsupported platforms
  }

  /// Save a file manually with a UUID name (if already picked externally)
  Future<String> saveToSafeStorage(File pickedFile, String fileName) async {
    final safeDir = await getSafeDirectory(fileName);
    final ext = path.extension(pickedFile.path);
    final newName = '${_uuid.v4()}$ext';
    final savedFile = File('${safeDir.path}/$newName');
    await pickedFile.copy(savedFile.path);
    return newName;
  }

  /// Get a file by its name
  Future<File?> getImageByName(String fileName, String dirName) async {
    final safeDir = await getSafeDirectory(dirName);
    final file = File('${safeDir.path}/$fileName');
    return await file.exists() ? file : null;
  }

  /// Delete a file by name
  Future<bool> deleteImageByName(String fileName, String dirName) async {
    final file = await getImageByName(fileName, dirName);
    if (file != null) {
      await file.delete();
      return true;
    }
    return false;
  }

  /// List all saved files
  Future<List<File>> listSavedImages(String dirName) async {
    final dir = await getSafeDirectory(dirName);
    return dir.listSync().whereType<File>().toList();
  }

  /// Deletes all images from the internal safe directory
  Future<void> clearAllImages(String dirName) async {
    final dir = await getSafeDirectory(dirName);

    if (await dir.exists()) {
      final files = dir.listSync().whereType<File>();
      for (final file in files) {
        try {
          await file.delete();
        } catch (e) {
          print('Failed to delete file: ${file.path}, error: $e');
        }
      }
    }
  }
}

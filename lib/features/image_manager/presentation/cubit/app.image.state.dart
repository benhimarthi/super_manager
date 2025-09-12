import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/app.image.dart';

abstract class AppImageState extends Equatable {
  const AppImageState();

  @override
  List<Object?> get props => [];
}

class AppImageManagerLoading extends AppImageState {}

class AppImageUpdatedSuccessfully extends AppImageState {}

class LoadedAllImagesFromDirectorySuccessfully extends AppImageState {
  final List<File> images;
  const LoadedAllImagesFromDirectorySuccessfully(this.images);
}

class AppImageProductLoaded extends AppImageState {
  final List<AppImage> images;

  const AppImageProductLoaded(this.images);

  @override
  List<Object?> get props => [images];
}

class AppImageProfileLoaded extends AppImageState {
  final List<AppImage> images;

  const AppImageProfileLoaded(this.images);

  @override
  List<Object?> get props => [images];
}

class AppImageCategoryLoaded extends AppImageState {
  final List<AppImage> images;

  const AppImageCategoryLoaded(this.images);

  @override
  List<Object?> get props => [images];
}

class AppImageManagerLoaded extends AppImageState {
  final List<AppImage> images;

  const AppImageManagerLoaded(this.images);

  @override
  List<Object?> get props => [images];
}

class DeleteImageFromDirectorySuccessfully extends AppImageState {}

class GetAppImageByIdSuccessfully extends AppImageState {
  final AppImage image;
  const GetAppImageByIdSuccessfully(this.image);
}

class OpenImageFromGalerySuccessfully extends AppImageState {
  final File? imageLink;
  const OpenImageFromGalerySuccessfully(this.imageLink);
}

class OpenProfileImageFromGalerySuccessfully extends AppImageState {
  final File? imageLink;
  const OpenProfileImageFromGalerySuccessfully(this.imageLink);
}

class AppImageManagerError extends AppImageState {
  final String message;

  const AppImageManagerError(this.message);

  @override
  List<Object?> get props => [message];
}

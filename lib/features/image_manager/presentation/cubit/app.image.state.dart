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

class AppImageManagerLoaded extends AppImageState {
  final List<AppImage> images;

  const AppImageManagerLoaded(this.images);

  @override
  List<Object?> get props => [images];
}

class GetAppImageByIdSuccessfully extends AppImageState {
  final AppImage image;
  const GetAppImageByIdSuccessfully(this.image);
}

class OpenImageFromGalerySuccessfully extends AppImageState {
  final File? imageLink;
  const OpenImageFromGalerySuccessfully(this.imageLink);
}

class AppImageManagerError extends AppImageState {
  final String message;

  const AppImageManagerError(this.message);

  @override
  List<Object?> get props => [message];
}

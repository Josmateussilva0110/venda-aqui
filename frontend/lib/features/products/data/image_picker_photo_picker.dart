import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/photo_picker.dart';
import '../domain/product.dart';

class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  // Reduz a foto no aparelho: a lista mostra miniaturas e o limite do servidor é 5 MB
  static const _maxDimension = 1280.0;
  static const _jpegQuality = 80;

  // Miniatura das listas: o menor lado com 256 px cobre o maior avatar (56 dp) em telas de até 4x
  static const _thumbMinSide = 256;
  static const _thumbQuality = 70;
  static const _typesByExtension = {'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png', 'webp': 'image/webp'};

  @override
  Future<PhotoPickResult> pick(PhotoOrigin origin) async {
    final file = await _picker.pickImage(
      source: origin == PhotoOrigin.camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
      imageQuality: _jpegQuality,
    );
    if (file == null) return const PhotoCancelled();

    final contentType = file.mimeType ?? _typesByExtension[file.name.split('.').last.toLowerCase()];
    if (contentType == null || !ProductPhoto.supportedTypes.contains(contentType)) return const PhotoUnsupported();

    final bytes = await file.readAsBytes();
    if (bytes.length > ProductPhoto.maxBytes) return const PhotoTooLarge();
    return PhotoPicked(ProductPhoto(bytes: bytes, contentType: contentType, thumbBytes: await _thumbnailOf(bytes)));
  }

  /// Sem miniatura a foto ainda é salva; as listas só passam a baixar a foto inteira.
  Future<Uint8List?> _thumbnailOf(Uint8List bytes) async {
    try {
      return await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: _thumbMinSide,
        minHeight: _thumbMinSide,
        quality: _thumbQuality,
        format: CompressFormat.jpeg,
      );
    } on Object catch (error) {
      if (kDebugMode) debugPrint('Miniatura não gerada: ${error.runtimeType}');
      return null;
    }
  }
}

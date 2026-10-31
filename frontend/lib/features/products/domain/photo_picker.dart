import 'product.dart';

enum PhotoOrigin { camera, gallery }

sealed class PhotoPickResult {
  const PhotoPickResult();
}

final class PhotoPicked extends PhotoPickResult {
  const PhotoPicked(this.photo);
  final ProductPhoto photo;
}

final class PhotoCancelled extends PhotoPickResult {
  const PhotoCancelled();
}

final class PhotoTooLarge extends PhotoPickResult {
  const PhotoTooLarge();
}

final class PhotoUnsupported extends PhotoPickResult {
  const PhotoUnsupported();
}

/// Acesso à câmera/galeria, separado para a tela não depender do plugin.
abstract interface class PhotoPicker {
  Future<PhotoPickResult> pick(PhotoOrigin origin);
}

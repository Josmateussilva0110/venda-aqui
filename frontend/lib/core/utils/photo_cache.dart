import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Cache em disco das miniaturas das listas. O padrão do pacote guarda só 200 imagens,
/// e um estoque maior que isso voltaria a baixar as primeiras a cada rolagem completa.
abstract final class PhotoCache {
  static const _key = 'productThumbs';

  // ~10–20 KB por miniatura: 2 mil ocupam algo entre 20 e 40 MB
  static const _maxThumbs = 2000;

  // O caminho da foto muda a cada troca, então a mesma URL nunca fica velha
  static const _stalePeriod = Duration(days: 60);

  static final thumbs = CacheManager(Config(_key, maxNrOfCacheObjects: _maxThumbs, stalePeriod: _stalePeriod));
}

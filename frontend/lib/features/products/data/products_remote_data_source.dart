import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_codes.dart';
import '../../../core/network/app_failure.dart';
import '../../../core/network/cancel_signal.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/network/request_data.dart';
import '../domain/product.dart';
import 'product_dto.dart';

/// Rotas de produtos. Tudo que vai ao backend passa por [requestData]; só o envio do arquivo
/// da foto vai direto ao Storage (URL assinada), fora da API.
class ProductsRemoteDataSource {
  ProductsRemoteDataSource({required this._storageClient});

  /// Cliente sem o token da API: a foto vai direto ao Storage pela URL assinada.
  final Dio _storageClient;

  Future<ProductPage> list({
    required String search,
    required StockFilter filter,
    required int offset,
    required int limit,
    CancelSignal? cancel,
  }) async {
    final response = await requestData<ProductPage>(
      endpoint: ApiPaths.products,
      params: {'search': search, 'stockLevel': ProductDto.filterQuery(filter), 'offset': offset, 'limit': limit},
      cancelToken: cancel?.token,
      parse: (json) => ProductDto.pageFromJson(jsonMap(json)),
    );
    return response.requireData();
  }

  Future<Product> get(String id) async {
    final response = await requestData<Product>(endpoint: ApiPaths.product(id), parse: (json) => ProductDto.fromJson(jsonMap(json)));
    return response.requireData();
  }

  Future<String> create(ProductInput input) async {
    final response = await requestData<String>(
      endpoint: ApiPaths.products,
      method: 'POST',
      data: ProductDto.toJson(input),
      parse: (json) => jsonMap(json).requireString('id'),
    );
    return response.requireData();
  }

  Future<void> update(String id, ProductInput input) async {
    final response = await requestData<void>(endpoint: ApiPaths.product(id), method: 'PUT', data: ProductDto.toJson(input));
    response.ensureSuccess();
  }

  Future<void> restock(String id, double quantity) async {
    final response = await requestData<void>(endpoint: ApiPaths.productRestock(id), method: 'POST', data: {'quantity': quantity});
    response.ensureSuccess();
  }

  Future<void> uploadPhoto(String id, ProductPhoto photo) async {
    final target = await requestData<({String photoUrl, String path, String thumbUrl})>(
      endpoint: ApiPaths.productPhotoUploadUrl(id),
      method: 'POST',
      data: {'contentType': photo.contentType},
      parse: (json) {
        final data = jsonMap(json);
        return (
          photoUrl: data.requireString('signedUrl'),
          path: data.requireString('path'),
          thumbUrl: data.requireMap('thumb').requireString('signedUrl'),
        );
      },
    );
    final (:photoUrl, :path, :thumbUrl) = target.requireData();
    if (!_isHttps(photoUrl) || !_isHttps(thumbUrl)) throw const ServerFailure();

    final thumbBytes = photo.thumbBytes;
    await Future.wait([_sendToStorage(photoUrl, photo.bytes, photo.contentType), if (thumbBytes != null) _sendThumb(thumbUrl, thumbBytes)]);

    final confirmation = await requestData<void>(endpoint: ApiPaths.productPhoto(id), method: 'PUT', data: {'path': path});
    confirmation.ensureSuccess();
  }

  bool _isHttps(String url) => Uri.tryParse(url)?.scheme == 'https';

  // A miniatura é só economia de dados: se falhar, o servidor salva a foto sem ela
  Future<void> _sendThumb(String signedUrl, Uint8List bytes) async {
    try {
      await _sendToStorage(signedUrl, bytes, ProductPhoto.thumbContentType);
    } on AppFailure {
      return;
    }
  }

  Future<void> _sendToStorage(String signedUrl, Uint8List bytes, String contentType) async {
    try {
      await _storageClient.put<Object?>(
        signedUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(headers: {Headers.contentTypeHeader: contentType, Headers.contentLengthHeader: bytes.length}),
      );
    } on DioException catch (error) {
      throw error.response == null ? const NetworkFailure() : const ServerFailure();
    }
  }
}

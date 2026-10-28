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
    final target = await requestData<({String signedUrl, String path})>(
      endpoint: ApiPaths.productPhotoUploadUrl(id),
      method: 'POST',
      data: {'contentType': photo.contentType},
      parse: (json) {
        final data = jsonMap(json);
        return (signedUrl: data.requireString('signedUrl'), path: data.requireString('path'));
      },
    );
    final (:signedUrl, :path) = target.requireData();
    if (Uri.tryParse(signedUrl)?.scheme != 'https') throw const ServerFailure();

    await _sendToStorage(signedUrl, photo);

    final confirmation = await requestData<void>(endpoint: ApiPaths.productPhoto(id), method: 'PUT', data: {'path': path});
    confirmation.ensureSuccess();
  }

  Future<void> _sendToStorage(String signedUrl, ProductPhoto photo) async {
    try {
      await _storageClient.put<Object?>(
        signedUrl,
        data: Stream.fromIterable([photo.bytes]),
        options: Options(headers: {Headers.contentTypeHeader: photo.contentType, Headers.contentLengthHeader: photo.bytes.length}),
      );
    } on DioException catch (error) {
      throw error.response == null ? const NetworkFailure() : const ServerFailure();
    }
  }
}

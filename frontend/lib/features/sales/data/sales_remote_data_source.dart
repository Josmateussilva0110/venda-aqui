import '../../../core/network/api_codes.dart';
import '../../../core/network/cancel_signal.dart';
import '../../../core/network/json_map.dart';
import '../../../core/network/json_reader.dart';
import '../../../core/network/request_data.dart';
import '../domain/sale.dart';
import 'sale_dto.dart';

/// Vendas na API. O servidor calcula preço e total, baixa o estoque e mexe no saldo do fiado.
class SalesRemoteDataSource {
  const SalesRemoteDataSource();

  /// Devolve o id e o total calculado pelo servidor.
  Future<({String id, int totalCents})> register(SaleInput input) async {
    final response = await requestData<({String id, int totalCents})>(
      endpoint: ApiPaths.sales,
      method: 'POST',
      data: SaleDto.toJson(input),
      parse: _savedFromJson,
    );
    return response.requireData();
  }

  Future<({String id, int totalCents})> update(String id, SaleInput input) async {
    final response = await requestData<({String id, int totalCents})>(
      endpoint: ApiPaths.sale(id),
      method: 'PUT',
      data: SaleDto.toJson(input),
      parse: _savedFromJson,
    );
    return response.requireData();
  }

  Future<Sale> get(String id) async {
    final response = await requestData<Sale>(endpoint: ApiPaths.sale(id), parse: (json) => SaleDto.fromJson(jsonMap(json)));
    return response.requireData();
  }

  Future<SaleHistoryPage> history(SaleFilter filter, {required int offset, required int limit, CancelSignal? cancel}) async {
    // Dias inteiros no fuso do aparelho; o fim é exclusivo (meia-noite do dia seguinte)
    final from = DateTime(filter.from.year, filter.from.month, filter.from.day);
    final until = DateTime(filter.to.year, filter.to.month, filter.to.day + 1);
    final response = await requestData<SaleHistoryPage>(
      endpoint: ApiPaths.sales,
      params: {
        'from': from.toUtc().toIso8601String(),
        'to': until.toUtc().toIso8601String(),
        'paymentMethod': filter.method?.apiValue,
        'search': filter.search,
        'offset': offset,
        'limit': limit,
      },
      cancelToken: cancel?.token,
      parse: (json) {
        final data = jsonMap(json);
        return SaleHistoryPage(
          items: data.requireMapList('items').map(SaleDto.fromJson).toList(growable: false),
          total: data.requireInt('total'),
          totalCents: data.requireInt('totalCents'),
        );
      },
    );
    return response.requireData();
  }

  ({String id, int totalCents}) _savedFromJson(Object? json) {
    final data = jsonMap(json);
    return (id: data.requireString('id'), totalCents: data.requireInt('totalCents'));
  }
}

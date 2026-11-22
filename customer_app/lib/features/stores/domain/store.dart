import 'package:flutter/foundation.dart';

/// Loja ligada ao acesso do cliente, com o fiado dele lá.
@immutable
class Store {
  const Store({
    required this.id,
    required this.merchantName,
    required this.customerName,
    required this.balanceCents,
    required this.creditDueDate,
  });

  /// Id do cadastro do cliente nesta loja; é o que o extrato pede.
  final String id;
  final String merchantName;

  /// Nome com que a loja cadastrou o cliente.
  final String customerName;

  /// Quanto o cliente deve nesta loja, calculado pelo servidor.
  final int balanceCents;
  final DateTime? creditDueDate;

  bool get owes => balanceCents > 0;
}

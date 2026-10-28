import 'package:flutter/foundation.dart';

@immutable
class Merchant {
  const Merchant({required this.id, required this.name, required this.phone});

  final String id;
  final String name;

  /// Formato E.164 devolvido pela API (+5586999990000).
  final String phone;
}

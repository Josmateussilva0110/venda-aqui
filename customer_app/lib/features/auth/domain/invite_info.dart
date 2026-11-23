import 'package:flutter/foundation.dart';

/// O que a tela do link mostra antes de pedir o PIN.
@immutable
class InviteInfo {
  const InviteInfo({required this.merchantName, required this.phoneEnding, required this.hasAccount});

  final String merchantName;

  /// Só os 4 últimos dígitos do telefone do cadastro, para o cliente reconhecer o número.
  final String phoneEnding;

  /// Já existe acesso para esse telefone: pede o PIN atual (ou a criação de um novo).
  final bool hasAccount;
}

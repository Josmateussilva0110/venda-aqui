import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';

/// Fundo branco com área segura usado pelas telas de autenticação.
class AuthPageFrame extends StatelessWidget {
  const AuthPageFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(bottom: false, child: child),
    );
  }
}

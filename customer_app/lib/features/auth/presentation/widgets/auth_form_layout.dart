import 'package:flutter/material.dart';

import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/theme_menu_button.dart';

/// Coluna centralizada e rolável das telas de acesso, com a marca no topo e largura limitada em telas largas.
class AuthFormLayout extends StatelessWidget {
  const AuthFormLayout({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(spacing.xxl, spacing.xxl, spacing.xxl, spacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: BrandLogo(
                        markSize: context.sizes.logoMedium,
                        fontSize: context.text.headlineMedium?.fontSize ?? context.sizes.logoMedium,
                      ),
                    ),
                  ),
                  const ThemeMenuButton(),
                ],
              ),
              SizedBox(height: spacing.lg),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

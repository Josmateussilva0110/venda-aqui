import 'package:flutter/material.dart';

import '../theme/theme_context.dart';
import '../utils/initials.dart';

/// Foto do produto ou, sem foto, quadrado colorido com as iniciais.
class ProductAvatar extends StatelessWidget {
  const ProductAvatar({super.key, required this.name, required this.colorSeed, required this.size, this.photoUrl});

  final String name;
  final String colorSeed;
  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tile = context.colors.tileFor(hueOf(colorSeed));
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final fallback = Center(
      child: Text(initialsOf(name), style: context.text.titleMedium?.copyWith(color: tile.foreground), maxLines: 1),
    );

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.radius.md),
        child: SizedBox.square(
          dimension: size,
          child: ColoredBox(
            color: tile.background,
            child: photoUrl == null
                ? fallback
                : Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    // Decodifica no tamanho exibido, não na resolução original da foto
                    cacheWidth: (size * pixelRatio).round(),
                    errorBuilder: (_, _, _) => fallback,
                  ),
          ),
        ),
      ),
    );
  }
}

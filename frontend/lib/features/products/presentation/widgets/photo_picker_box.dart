import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/initials.dart';
import '../../../../l10n/app_localizations.dart';

/// Área tracejada da foto do produto: mostra a foto escolhida, a atual ou as iniciais.
class PhotoPickerBox extends StatelessWidget {
  const PhotoPickerBox({super.key, required this.name, required this.onTap, this.pickedBytes, this.currentUrl});

  final String name;
  final VoidCallback onTap;
  final Uint8List? pickedBytes;
  final String? currentUrl;

  static const _placeholderSymbol = '+';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final hasPhoto = pickedBytes != null || currentUrl != null;
    final height = context.sizes.photoBoxHeight;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final initials = name.trim().isEmpty ? _placeholderSymbol : initialsOf(name);

    Widget? image;
    if (pickedBytes != null) {
      image = Image.memory(pickedBytes!, fit: BoxFit.cover, cacheHeight: (height * pixelRatio).round());
    } else if (currentUrl != null) {
      image = CachedNetworkImage(
        imageUrl: currentUrl!,
        fit: BoxFit.cover,
        memCacheHeight: (height * pixelRatio).round(),
        errorWidget: (_, _, _) => const SizedBox.shrink(),
      );
    }

    return Semantics(
      button: true,
      label: hasPhoto ? l10n.productPhotoChange : l10n.productPhotoPick,
      excludeSemantics: true,
      child: Material(
        color: colors.surfaceMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.radius.xxl),
          side: BorderSide(color: colors.dashed, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ?image,
                Align(
                  alignment: hasPhoto ? Alignment.bottomCenter : Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(context.spacing.sm),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!hasPhoto) Text(initials, style: context.text.headlineMedium?.copyWith(color: colors.subtle)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: context.spacing.sm, vertical: context.spacing.xxs),
                          decoration: hasPhoto
                              ? BoxDecoration(
                                  color: colors.surface.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(context.radius.pill),
                                )
                              : null,
                          child: Text(
                            hasPhoto ? l10n.productPhotoChange : l10n.productPhotoPick,
                            style: context.text.labelSmall?.copyWith(color: colors.muted),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

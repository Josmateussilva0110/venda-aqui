import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context.dart';

/// Folha do Vendaqui (mesmo desenho do SVG do protótipo, viewBox 64×64).
class LeafMark extends StatelessWidget {
  const LeafMark({super.key, required this.size, required this.leftLeaf, required this.rightLeaf, required this.dot});

  final double size;
  final Color leftLeaf;
  final Color rightLeaf;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _LeafPainter(leftLeaf: leftLeaf, rightLeaf: rightLeaf, dot: dot),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  const _LeafPainter({required this.leftLeaf, required this.rightLeaf, required this.dot});

  final Color leftLeaf;
  final Color rightLeaf;
  final Color dot;

  static const _viewBox = 64.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _viewBox);
    canvas.drawCircle(const Offset(32, 8), 5, Paint()..color = dot);

    // translate(0 6) scale(.9) translate(3.5 0), igual ao SVG original
    canvas
      ..save()
      ..translate(0, 6)
      ..scale(0.9)
      ..translate(3.5, 0);
    final left = Path()
      ..moveTo(31, 56)
      ..cubicTo(16, 52, 8, 38, 10, 12)
      ..relativeCubicTo(15, 5, 23, 20, 21, 44)
      ..close();
    final right = Path()
      ..moveTo(33, 56)
      ..relativeCubicTo(15, -4, 23, -18, 21, -44)
      ..relativeCubicTo(-15, 5, -23, 20, -21, 44)
      ..close();
    canvas
      ..drawPath(left, Paint()..color = leftLeaf)
      ..drawPath(right, Paint()..color = rightLeaf)
      ..restore();
  }

  @override
  bool shouldRepaint(_LeafPainter oldDelegate) =>
      oldDelegate.leftLeaf != leftLeaf || oldDelegate.rightLeaf != rightLeaf || oldDelegate.dot != dot;
}

enum BrandTone { onLight, onPrimary }

/// Folha + "Vendaqui" em Manrope ExtraBold.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, required this.markSize, required this.fontSize, this.tone = BrandTone.onLight});

  final double markSize;
  final double fontSize;
  final BrandTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final onPrimary = tone == BrandTone.onPrimary;
    final baseColor = onPrimary ? colors.onPrimary : colors.ink;
    final accent = onPrimary ? colors.primaryTint : colors.primary;
    final style = AppTypography.wordmark(fontSize: fontSize, color: baseColor);

    return Semantics(
      label: l10n.appTitle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LeafMark(
            size: markSize,
            leftLeaf: onPrimary ? colors.onPrimary : colors.primary,
            rightLeaf: onPrimary ? colors.primaryTint : colors.leafLight,
            dot: onPrimary ? colors.onPrimary : colors.primaryDark,
          ),
          SizedBox(width: context.spacing.sm),
          // Encolhe a marca em vez de cortar quando a fonte do sistema está grande
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ExcludeSemantics(
                child: Text.rich(
                  TextSpan(
                    text: l10n.brandPrefix,
                    children: [
                      TextSpan(
                        text: l10n.brandSuffix,
                        style: TextStyle(color: accent),
                      ),
                    ],
                  ),
                  style: style,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

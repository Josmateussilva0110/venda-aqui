import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context.dart';

/// Folha do Vendaqui dentro do "C" de cliente (o mesmo desenho do ícone do app, design/icon/).
class ClientMark extends StatelessWidget {
  const ClientMark({super.key, required this.size, required this.ring, required this.leftLeaf, required this.rightLeaf, required this.dot});

  final double size;
  final Color ring;
  final Color leftLeaf;
  final Color rightLeaf;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _ClientMarkPainter(ring: ring, leftLeaf: leftLeaf, rightLeaf: rightLeaf, dot: dot),
      ),
    );
  }
}

class _ClientMarkPainter extends CustomPainter {
  const _ClientMarkPainter({required this.ring, required this.leftLeaf, required this.rightLeaf, required this.dot});

  final Color ring;
  final Color leftLeaf;
  final Color rightLeaf;
  final Color dot;

  // Desenho num quadrado de 100: anel de raio 44 aberto para a direita e a folha (viewBox 64) no centro
  static const _viewBox = 100.0;
  static const _ringRadius = 44.0;
  static const _ringStroke = 7.7;
  static const _ringGap = 38 * math.pi / 180;
  static const _leafOffset = Offset(18, 21.8);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _viewBox);
    final ringPaint = Paint()
      ..color = ring
      ..style = PaintingStyle.stroke
      ..strokeWidth = _ringStroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(_viewBox / 2, _viewBox / 2), radius: _ringRadius),
      _ringGap,
      2 * math.pi - 2 * _ringGap,
      false,
      ringPaint,
    );

    canvas.translate(_leafOffset.dx, _leafOffset.dy);
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
  bool shouldRepaint(_ClientMarkPainter oldDelegate) =>
      oldDelegate.ring != ring || oldDelegate.leftLeaf != leftLeaf || oldDelegate.rightLeaf != rightLeaf || oldDelegate.dot != dot;
}

enum BrandTone { onLight, onPrimary }

/// Marca + "Vendaqui Cliente" em Manrope ExtraBold, com "Cliente" mais leve.
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
    final audienceColor = onPrimary ? colors.onPrimaryMuted : colors.muted;
    final style = AppTypography.wordmark(fontSize: fontSize, color: baseColor);

    return Semantics(
      label: l10n.appTitle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClientMark(
            size: markSize,
            ring: onPrimary ? colors.primaryTint : colors.leafLight,
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
                      TextSpan(
                        text: ' ${l10n.brandAudience}',
                        style: TextStyle(color: audienceColor, fontWeight: FontWeight.w600),
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

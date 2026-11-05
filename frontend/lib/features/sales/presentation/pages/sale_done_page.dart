import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/sale.dart';
import '../widgets/payment_method_style.dart';

/// Venda registrada: confirma o total e volta sozinha para o início depois de alguns segundos.
class SaleDonePage extends StatefulWidget {
  const SaleDonePage({super.key, required this.sale});

  final Sale sale;

  @override
  State<SaleDonePage> createState() => _SaleDonePageState();
}

class _SaleDonePageState extends State<SaleDonePage> {
  static const _autoReturnSeconds = 5;

  late int _secondsLeft = _autoReturnSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) return _goHome();
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goHome() {
    _timer?.cancel();
    if (mounted) context.go(AppRoutes.home);
  }

  void _newSale() {
    _timer?.cancel();
    context.go(AppRoutes.sell);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final sale = widget.sale;

    return PopScope(
      // Voltar daqui leva ao início, não ao pagamento de uma venda já registrada
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        // Fundo verde: ícones claros na barra de status
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: colors.primary,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(spacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppBreakpoints.formMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: colors.onPrimary, shape: BoxShape.circle),
                          child: Padding(
                            padding: EdgeInsets.all(spacing.lg),
                            child: Icon(Icons.check_rounded, color: colors.primary, size: context.sizes.iconLarge * 2),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing.xl),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          l10n.saleDoneTitle,
                          textAlign: TextAlign.center,
                          style: context.text.headlineMedium?.copyWith(color: colors.onPrimary),
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          MoneyFormat.format(sale.totalCents),
                          style: context.text.displayMedium?.copyWith(color: colors.onPrimary),
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      Text(
                        '${_methodLabel(l10n, sale)} · ${l10n.cartItemCount(sale.itemCount)}',
                        textAlign: TextAlign.center,
                        style: context.text.titleSmall?.copyWith(color: colors.onPrimaryMuted),
                      ),
                      SizedBox(height: spacing.huge),
                      AppButton(label: l10n.saleDoneNewSale, variant: AppButtonVariant.light, onPressed: _newSale),
                      SizedBox(height: spacing.sm),
                      TextButton(
                        onPressed: _goHome,
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onPrimary,
                          minimumSize: Size.fromHeight(context.sizes.minTouchTarget),
                        ),
                        child: Text(l10n.saleDoneBackHome, style: context.text.titleSmall?.copyWith(color: colors.onPrimary)),
                      ),
                      Text(
                        l10n.saleDoneCountdown(_secondsLeft),
                        textAlign: TextAlign.center,
                        style: context.text.bodySmall?.copyWith(color: colors.onPrimaryMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _methodLabel(AppLocalizations l10n, Sale sale) {
  final customer = sale.customer;
  return customer == null ? sale.method.label(l10n) : l10n.saleDoneCredit(customer.name);
}
